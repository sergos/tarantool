/*
 * Copyright 2010-2022, Tarantool AUTHORS, please see AUTHORS file.
 *
 * Redistribution and use in source and binary forms, with or
 * without modification, are permitted provided that the following
 * conditions are met:
 *
 * 1. Redistributions of source code must retain the above
 *    copyright notice, this list of conditions and the
 *    following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * <COPYRIGHT HOLDER> OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
#include "thread.h"

#include "space.h"
#include "trigger.h"
#include "wal.h"

struct box_thread_pool {
	/** Size of @a threads array - number of available box threads. */
	size_t size;
	/** Array of box threads. */
	struct box_thread *threads;
	/** Used to put threads back into pool - rlist is not lock-free. */
	pthread_mutex_t mutex;
	/** List of inactive threads. */
	struct rlist idle_threads;
	/** List to find thread by name in wal_write. */
	struct rlist active_threads;
};

struct box_thread_pool box_thread_pool;

int
box_thread_check_main()
{
	if (cord_is_main())
		return 0;
	diag_set(ClientError, ER_BOX_THREAD,
		 "This operation can be performed only on main thread");
	return -1;
}

struct box_thread *
box_thread_pool_get_thread(size_t i)
{
	return &box_thread_pool.threads[i];
}

static void
box_prio_cb(struct ev_loop *loop, ev_watcher *watcher, int events)
{
	(void) loop;
	(void) events;
	struct cbus_endpoint *endpoint = (struct cbus_endpoint *)watcher->data;
	cbus_process(endpoint);
}

static int
box_thread_f(va_list ap)
{
	struct box_thread *thread = va_arg(ap, struct box_thread *);
	/* Used to receive messages from TX (aka box-main) thread. */
	cbus_endpoint_create(&thread->endpoint, thread->name,
			     fiber_schedule_cb, fiber());
	/* Analogue of tx_prio pipe/endpoint for WAL. */
	char endpoint_name[FIBER_NAME_MAX];
	snprintf(endpoint_name, FIBER_NAME_MAX, "%s_prio", thread->name);
	cbus_endpoint_create(&thread->endpoint_prio, endpoint_name,
			     box_prio_cb, &thread->endpoint_prio);
	cpipe_create(&thread->wal_pipe, "wal");
	cpipe_set_max_input(&thread->wal_pipe, IOV_MAX);
	cbus_loop(&thread->endpoint);
	cbus_endpoint_destroy(&thread->endpoint, cbus_process);
	cbus_endpoint_destroy(&thread->endpoint_prio, cbus_process);
	cpipe_destroy(&thread->wal_pipe);
	return 0;
}

static void
box_thread_init(struct box_thread *thread, size_t numb)
{
	struct box_thread_pool *pool = &box_thread_pool;
	thread->wal_request_route[0].f = wal_write_to_disk;
	thread->wal_request_route[0].pipe = &thread->box_pipe;
	thread->wal_request_route[1].f = tx_complete_batch;
	thread->wal_request_route[1].pipe = NULL;
	snprintf(thread->name, sizeof(thread->name), "box_thread_%lu", numb);
	rlist_create(&thread->in_active);
	rlist_add_tail_entry(&pool->idle_threads, thread, in_idle);
	mempool_create(&thread->msg_pool, &cord()->slabc,
		       sizeof(struct box_msg));
	if (cord_costart(&thread->cord, thread->name, box_thread_f,
			 thread) != 0)
		panic("Failed to start box thread!");
	cpipe_create(&thread->tx_pipe, thread->name);
}

void
box_init_thread_pool()
{
	assert(cord_is_main());
	struct box_thread_pool *pool = &box_thread_pool;
	pool->size = BOX_THREAD_COUNT_DEFAULT;
	rlist_create(&pool->idle_threads);
	rlist_create(&pool->active_threads);
	size_t threads_sz = sizeof(struct box_thread) * pool->size;
	pool->threads = (struct box_thread *) malloc(threads_sz);
	if (pool->threads == NULL)
		panic("Failed to allocated box thread pool!");
	tt_pthread_mutex_init(&pool->mutex, NULL);
	for (size_t i = 0; i < pool->size; ++i)
		box_thread_init(&pool->threads[i], i);
}

void
box_destroy_thread_pool()
{
	assert(cord_is_main());
	tt_pthread_mutex_trylock(&box_thread_pool.mutex);
	tt_pthread_mutex_unlock(&box_thread_pool.mutex);
	for (size_t i = 0; i < box_thread_pool.size; ++i) {
		struct box_thread *thread = &box_thread_pool.threads[i];
		tt_pthread_cancel(thread->cord.id);
		tt_pthread_join(thread->cord.id, NULL);
		cpipe_destroy(&thread->tx_pipe);
		mempool_destroy(&thread->msg_pool);
	}
	free(box_thread_pool.threads);
	tt_pthread_mutex_destroy(&box_thread_pool.mutex);
}


/** Must be called in WAL thread. */
void
box_thread_init_box_pipes()
{
	for (size_t i = 0; i < box_thread_pool.size; ++i) {
		struct box_thread *thread = &box_thread_pool.threads[i];
		char endpoint_name[FIBER_NAME_MAX];
		snprintf(endpoint_name, FIBER_NAME_MAX, "%s_prio", thread->name);
		cpipe_create(&thread->box_pipe, endpoint_name);
	}
}

void
box_thread_destroy_box_pipes()
{
	/* Make sure threads are not involved in any . */
	tt_pthread_mutex_lock(&box_thread_pool.mutex);
	tt_pthread_mutex_unlock(&box_thread_pool.mutex);

	for (size_t i = 0; i < box_thread_pool.size; ++i) {
		struct box_thread *thread = &box_thread_pool.threads[i];
		cpipe_destroy(&thread->box_pipe);
	}
}

struct cmsg_hop *
box_thread_get_wal_route()
{
	struct cord *current_cord = cord();
	for (size_t i = 0; i < box_thread_pool.size; ++i) {
		struct box_thread *thread = &box_thread_pool.threads[i];
		if (strcmp(current_cord->name, thread->cord.name) == 0)
			return thread->wal_request_route;
	}
	return NULL;
}

struct box_thread *
box_thread_pool_get_idle()
{
	assert(cord_is_main());
	struct box_thread *idle = NULL;
	tt_pthread_mutex_lock(&box_thread_pool.mutex);
	if (! rlist_empty(&box_thread_pool.idle_threads)) {
		idle = rlist_first_entry(&box_thread_pool.idle_threads,
					 struct box_thread, in_idle);
	}
	tt_pthread_mutex_unlock(&box_thread_pool.mutex);
	return idle;
}

struct cpipe *
box_thread_get_wal_pipe()
{
	struct cord *current_cord = cord();
	for (size_t i = 0; i < box_thread_pool.size; ++i) {
		struct box_thread *thread = &box_thread_pool.threads[i];
		if (strcmp(current_cord->name, thread->cord.name) == 0)
			return &thread->wal_pipe;
	}
	return NULL;
}

struct box_thread *
box_thread_by_name(const char *name)
{
	for (size_t i = 0; i < box_thread_pool.size; ++i) {
		struct box_thread *thread = &box_thread_pool.threads[i];
		if (strcmp(name, thread->cord.name) == 0)
			return thread;
	}
	return NULL;
}

static struct box_msg *
box_thread_msg_create(struct box_thread *thread, const struct cmsg_hop *hop)
{
	assert(cord_is_main());
	struct box_msg *msg = (struct box_msg *) mempool_alloc(&thread->msg_pool);
	if (msg == NULL) {
		diag_set(OutOfMemory, sizeof(*msg), "mempool", "struct box_msg");
		return NULL;
	}
	cmsg_init(&msg->base, hop);
	msg->thread = thread;
	return msg;
}

/** Send the message to box_thread with */
int
box_thread_execute(struct box_thread *thread, const struct cmsg_hop *hop)
{
	assert(cord_is_main());
	struct box_msg *msg = box_thread_msg_create(thread, hop);
	if (msg == NULL)
		return -1;
	tt_pthread_mutex_lock(&box_thread_pool.mutex);
	rlist_del(&thread->in_idle);
	rlist_add_entry(&box_thread_pool.active_threads, thread, in_active);
	tt_pthread_mutex_unlock(&box_thread_pool.mutex);
	cpipe_push(&thread->tx_pipe, &msg->base);
	cpipe_flush_input(&thread->tx_pipe);
	return 0;
}

void
box_thread_cancel(struct box_thread *thread)
{
	(void) thread;
	//if (thread->status == BOX_THREAD_IS_IDLE)
		return;
}

void
box_thread_finish(struct box_thread *thread)
{
	region_free(&fiber()->gc);
	tt_pthread_mutex_lock(&box_thread_pool.mutex);
	rlist_del(&thread->in_active);
	rlist_add_entry(&box_thread_pool.idle_threads, thread, in_idle);
	tt_pthread_mutex_unlock(&box_thread_pool.mutex);
}