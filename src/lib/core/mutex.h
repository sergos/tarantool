#pragma once
/*
 * Copyright 2010-2021, Tarantool AUTHORS, please see AUTHORS file.
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
#include <assert.h>
#include "fiber.h"
#include "tt_pthread.h"


#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

enum {
	BOX_MUTEX_DEFAULT_TIMEOUT = 1
};

struct box_mutex {
	pthread_mutex_t mutex;
};

extern struct box_mutex *box_mutex;

static inline void
box_mutex_create()
{
	assert(box_mutex == NULL && "box mutex has been already created!");
	box_mutex = (struct box_mutex *) malloc(sizeof(*box_mutex));
	if (box_mutex == NULL)
		panic("Failed to allocate box mutex!");
	(void) tt_pthread_mutex_init(&box_mutex->mutex, NULL);
}

/** TODO: add queue of threads to acquire the lock. */
static inline int
box_mutex_lock()
{
	int err = 0;
	while ((err = tt_pthread_mutex_trylock(&box_mutex->mutex)) != 0) {
		if (err != EBUSY)
			return -1;
		fiber_sleep(0.5);
		say_error("Failed to lock mutex, yield!");
	}
	return 0;
}

static inline void
box_mutex_unlock()
{
	(void) tt_pthread_mutex_unlock(&box_mutex->mutex);

}

static inline void
box_mutex_destroy()
{
	(void) tt_pthread_mutex_lock(&box_mutex->mutex);
	(void) tt_pthread_mutex_unlock(&box_mutex->mutex);
	(void) tt_pthread_mutex_destroy(&box_mutex->mutex);
}

#if defined(__cplusplus)
} /* extern "C" */
#endif /* defined(__cplusplus) */
