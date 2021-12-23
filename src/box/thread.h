#pragma once
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
#include "lib/core/fiber.h"
#include "lib/core/cbus.h"

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

enum box_thread_status {
	BOX_THREAD_IS_ACTIVE = 0,
	BOX_THREAD_IS_IDLE = 1,
	BOX_THREAD_IS_FINISHED = 2
};

struct box_thread {
	/** Cord corresponding to the given thread. */
	struct cord cord;
	/** Freshly new lua state for this thread. */
	struct lua_State *state;
	/**
	 * List of inactive/active threads. While operating on these
	 * lists @box_thread_pool->mutex must be locked.
	 */
	struct rlist in_idle;
	struct rlist in_active;
	/** A pipe from this thread to WAL. */
	struct cpipe wal_pipe;
	/** A pipe from WAL to this thread. Should be initialized from WAL thread. */
	struct cpipe box_pipe;
	/** Route for WAL thread. */
	struct cmsg_hop wal_request_route[2];
	/** Endpoint for TX thread. */
	struct cbus_endpoint endpoint;
	/** Endpoint for WAL thread. */
	struct cbus_endpoint endpoint_prio;
	/**
	 * A pipe from TX thread to current one. Used to
	 * launch task on this thread.
	 */
	struct cpipe tx_pipe;
	/** Pool of TX->BOX messages which are supposed to be sent via tx_pipe.  */
	struct mempool msg_pool;
	/** Name of the given thread/cord. */
	char name[FIBER_NAME_MAX];
};

enum {
	BOX_THREAD_COUNT_DEFAULT = 4,
};

/** TX->BOX messages format. */
struct box_msg {
	struct cmsg base;
	struct box_thread *thread;
};

/** Sets diag in case this function is executed in any thread except for main. */
int
box_thread_check_main();


void
box_thread_init_box_pipes();

void
box_thread_destroy_box_pipes();

void
box_thread_init_wal_pipes();

void
box_thread_destroy_wal_pipes();

struct cmsg_hop *
box_thread_get_wal_route();

struct box_thread *
box_thread_pool_get_thread(size_t i);

/** Get pipe to WAL from current thread. */
struct cpipe *
box_thread_get_wal_pipe();

struct box_thread *
box_thread_pool_get_idle();

struct box_thread *
box_thread_by_name(const char *name);

int
box_thread_execute(struct box_thread *thread, const struct cmsg_hop *hop);

void
box_thread_finish(struct box_thread *thread);

void
box_init_thread_pool();

void
box_destroy_thread_pool();

#if defined(__cplusplus)
} /* extern "C" */
#endif /* defined(__cplusplus) */
