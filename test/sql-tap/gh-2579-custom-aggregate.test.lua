#!/usr/bin/env tarantool
local build_path = os.getenv("BUILDDIR")
package.cpath = build_path..'/test/sql-tap/?.so;'..build_path..
                '/test/sql-tap/?.dylib;'..package.cpath

local test = require("sqltester")
test:plan(5)

test:execsql([[
    CREATE TABLE t (i INT PRIMARY KEY);
    INSERT INTO t VALUES(1), (2), (3), (4), (5);
]])

-- Make sure that persistent aggregate functions work as intended.
box.schema.func.create("F1", {
    language = "Lua",
    body = [[
        function(x, state)
            if state == nil then
                state = {sum = 0, count = 0}
            end
            state.sum = state.sum + x
            state.count = state.count + 1
            return state
        end
    ]],
    param_list = {"integer", "map"},
    returns = "map",
    aggregate = "group",
    exports = {"SQL"},
})

test:do_execsql_test(
    "gh-2579-1",
    [[
        SELECT f1(i) from t;
    ]], {
        {sum = 15, count = 5}
    })

-- Make sure that non-persistent aggregate functions work as intended.
local f2 = function(x, state)
    if state == nil then
        state = {}
    end
    table.insert(state, x)
    return state
end

rawset(_G, 'F2', f2)

box.schema.func.create("F2", {
    language = "Lua",
    param_list = {"integer", "array"},
    returns = "array",
    aggregate = "group",
    exports = {"SQL"},
})

test:do_execsql_test(
    "gh-2579-2",
    [[
        SELECT f2(i) from t;
    ]], {
        {1, 2, 3, 4, 5}
    })

-- Make sure that C aggregate functions work as intended.
box.schema.func.create("gh-2579-custom-aggregate.f3", {
    language = "C",
    param_list = {"integer", "integer"},
    returns = "integer",
    aggregate = "group",
    exports = {"SQL"},
})

test:do_execsql_test(
    "gh-2579-3",
    [[
        SELECT "gh-2579-custom-aggregate.f3"(i) from t;
    ]], {
        55
    })

-- Make sure aggregate functions can't be called in Lua.
test:do_test(
    "gh-2579-4",
    function()
        local def = {aggregate = 'group', exports = {'LUA', 'SQL'}}
        local res = {pcall(box.schema.func.create, 'F4', def)}
        return {tostring(res[2])}
    end, {
        "Failed to create function 'F4': aggregate function can only be "..
        "accessed in SQL"
    })

-- Make sure aggregate functions can't have less that 1 argument.
test:do_test(
    "gh-2579-5",
    function()
        local def = {aggregate = 'group', exports = {'SQL'}}
        local res = {pcall(box.schema.func.create, 'F4', def)}
        return {tostring(res[2])}
    end, {
        "Failed to create function 'F4': aggregate function must have at "..
        "least one argument"
    })

box.schema.func.drop('gh-2579-custom-aggregate.f3')
box.schema.func.drop('F2')
box.schema.func.drop('F1')
test:execsql([[DROP TABLE t;]])

test:finish_test()
