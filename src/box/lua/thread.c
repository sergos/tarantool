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
#include "box/thread.h"
#include "fiber.h"
#include "../../lua/error.h"
#include "../error.h"
#include "lua/init.h"
#include "init.h" /** box_lua_init() */
#include "lua/utils.h"
#include "box/schema.h" /** space_foreach() */
#include "box/space.h" /** struct space */
#include "space.h" /** box_lua_space_new() */

static const char *threadlib_name = "box.thread";

static void
box_thread_process_lua(struct cmsg *m)
{
	struct box_msg *box_msg = (struct box_msg *) m;
	struct box_thread *thread = box_msg->thread;
	struct lua_State *state = thread->state;
	int top = lua_gettop(state);
	if (top != 1) {
		diag_set(ClientError, ER_BOX_THREAD,
			 "Failed to start thread: thread.new() must accept only one argument");
		diag_log();
		goto finish;
	}
	if (! lua_isstring(state, 1)) {
		diag_set(ClientError, ER_BOX_THREAD,
			 "Failed to start thread: argument of new thread function is expected to be string");
		diag_log();
		goto finish;
	}

	const char *load_str = lua_tostring(state, 1);
	if (luaL_loadstring(state, load_str) != 0) {
		diag_set(ClientError, ER_BOX_THREAD,
			 "Failed to start thread: failed to load Lua string!");
		diag_log();
		goto finish;
	}
	if (lua_pcall(state, 0, 0, 0) != 0) {
		diag_set(ClientError, ER_BOX_THREAD,
			 "Failed to call function %s",
			 luaT_tolstring(state, -1, NULL));
		diag_log();
		goto finish;
	}
	say_info("Lua pcall has finished!");
finish:
	lua_close(state);
	thread->state = NULL;
	box_thread_finish(thread);
}

static struct cmsg_hop process_lua_route[] = {
	{ box_thread_process_lua, NULL },
};

/** Push all existing spaces to new box. */
static int
lua_init_spaces(struct space *space, void *data)
{
	struct lua_State *new_state = (struct lua_State *) data;
	box_lua_space_new(new_state, space);
	return 0;
}

/**
 * Implement call of box.cfg{} in the state @a L.
 * TODO: pass all parameters from original box.cfg{}
 */
static void
lua_call_cfg(struct lua_State *L)
{
	lua_getfield(L, LUA_GLOBALSINDEX, "box");
	lua_getfield(L, -1, "cfg");
	lua_call(L, 0, 0);
	lua_pop(L, 1); /* box, cfg */
}

static void
lua_state_init_box(struct lua_State *new_state)
{
	lua_state_init_libs(new_state);
	lua_settop(new_state, 0);
	box_lua_init(new_state);
	lua_call_cfg(new_state);
	space_foreach(lua_init_spaces, (void *) new_state);
}

static int
lbox_thread_new(struct lua_State *L)
{
	/*
	 * In order to avoid races on box_threads let's allow threads to be
	 * created only from main.
	 */
	if (! cord_is_main())
		luaL_error(L, "Can't create box thread from an auxiliary thread");

	int top = lua_gettop(L);
	if (top != 1 || ! lua_isstring(L, 1))
		luaL_error(L, "Usage: box.thread.new('function')");

	const char *func = lua_tostring(L, 1);
	/* Create new thread, new lua state within it. */
	struct box_thread *new_thread = box_thread_pool_get_idle();
	if (new_thread == NULL) {
		return luaL_error(L, "Failed to start new box thread: "
				     "all threads are busy");
	}
	struct lua_State *new_state = luaL_newstate();
	if (new_state == NULL)
		return luaL_error(L, "Failed to create new Lua state");

	lua_state_init_box(new_state);
	new_thread->state = new_state;

	/*
	 * Push the string containing function to be called on the top
	 * of newly created Lua state.
	 */
	lua_pushstring(new_state, func);
	lua_createtable(L, 0, 2);


	return box_thread_execute(new_thread, process_lua_route);
}

//static int
//lbox_thread_stop(struct lua_State *L)
//{
//	(void) L;
//	if (! cord_is_main())
//		luaL_error(L, "Can't stop thread from an auxiliary thread");
//
//	int top = lua_gettop(L);
//	if (top != 1 || ! lua_isstring(L, 1))
//		luaL_error(L, "Usage: box.thread.stop('name')");
//
//	const char *thread_name = lua_tostring(L, 1);
//	struct box_thread *thread = box_thread_by_name(thread_name);
//	if (thread == NULL)
//		luaL_error(L, "No such thread");
//	box_thread_stop(thread);
//	return 0;
//}

static int
lbox_thread_list(struct lua_State *L)
{
	if (! cord_is_main())
		luaL_error(L, "Can't list threads from an auxiliary thread");
//	rlist_foreach_entry(thread, &pool, in_active) {
//		lua_pushstring(L, thread->cord.name);
//		lua_rawseti(L, -2, count++);
//	}
	for (size_t i = 0; i < BOX_THREAD_COUNT_DEFAULT; ++i) {
		struct box_thread *thread = box_thread_pool_get_thread(i);
		lua_newtable(L);
		lua_pushstring(L, thread->cord.name);
		if (! rlist_empty(&thread->in_active))
			lua_pushstring(L, "active");
		if (! rlist_empty(&thread->in_idle))
			lua_pushstring(L, "idle");
		lua_rawseti(L, -2, i);
	}
	return 1;
}

void
box_lua_thread_init(struct lua_State *L)
{
	static const struct luaL_Reg thread_methods[] = {
		{ "new",  lbox_thread_new },
		{ "list", lbox_thread_list },
		{ NULL,   NULL }
	};
	luaL_register_module(L, threadlib_name, thread_methods);
	lua_pop(L, 1);
	/* Should be called once. */
	if (L == tarantool_L)
		box_init_thread_pool();
}
