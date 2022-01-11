#!/usr/bin/env tarantool
local build_path = os.getenv("BUILDDIR")
package.cpath = build_path..'/test/sql-tap/?.so;'..build_path..'/test/sql-tap/?.dylib;'..package.cpath

local test = require("sqltester")
test:plan(15)

-- Make sure that non-persistent aggregate functions are working as expected.
local step = function(x, y)
    if x == nil then
        x = {sum = 0, count = 0}
    end
    x.sum = x.sum + y
    x.count = x.count + 1
    return x
end

local finalize = function(x)
    return x.sum / x.count
end

rawset(_G, 'S1', step)
rawset(_G, 'S1_finalize', finalize)
box.schema.func.create('S1', {aggregate = 'group', returns = 'number',
                              param_list = {'integer'}, exports = {'SQL'}})

test:execsql([[
    CREATE TABLE t(i INTEGER PRIMARY KEY AUTOINCREMENT, a INT);
    INSERT INTO t(a) VALUES(1), (1), (2), (2), (3);
]])

test:do_execsql_test(
    "gh-2579-1",
    [[
        SELECT avg(a), s1(a) FROM t;
    ]], {
        1, 1.8
    })

test:do_execsql_test(
    "gh-2579-2",
    [[
        SELECT avg(distinct a), s1(distinct a) FROM t;
    ]], {
        2, 2
    })

-- Make sure that persistent aggregate functions are working as expected.
local body_s2 = {
    step = [[function(x, y)
        if x == nil then
            x = {sum = 0, count = 0}
        end
        x.sum = x.sum + y
        x.count = x.count + 1
        return x
    end]],
    finalize = [[function(x)
        return x.sum / x.count
    end]]
}

box.schema.func.create('S2', {aggregate = 'group', returns = 'number',
                              body = body_s2, param_list = {'integer'},
                              exports = {'SQL'}})

test:do_execsql_test(
    "gh-2579-3",
    [[
        SELECT avg(a), s2(a) FROM t;
    ]], {
        1, 1.8
    })

test:do_execsql_test(
    "gh-2579-4",
    [[
        SELECT avg(distinct a), s2(distinct a) FROM t;
    ]], {
        2, 2
    })

-- Make sure that C aggregate functions are working as expected.
box.schema.func.create("gh-2579-custom-aggregate.S3", {
    language = "C", aggregate = 'group', param_list = {"integer"},
    returns = "number", exports = {"SQL"},
})

test:do_execsql_test(
    "gh-2579-5",
    [[
        SELECT "gh-2579-custom-aggregate.S3"(a) FROM t;
    ]], {
        0.9
    })

test:do_execsql_test(
    "gh-2579-6",
    [[
        SELECT "gh-2579-custom-aggregate.S3"(distinct a) FROM t;
    ]], {
        0.6
    })

--
-- Make sure that user-defined aggregate functions can have more than one
-- argument.
--
local body_s4 = {
    step = [[function(x, y, z)
        if x == nil then
            x = {sum = 0, count = 0}
        end
        x.sum = x.sum + y + z
        x.count = x.count + 1
        return x
    end]],
    finalize = [[function(x)
        return x.sum / x.count
    end]]
}
box.schema.func.create('S4', {aggregate = 'group', returns = 'number',
                              param_list = {'integer', 'integer'},
                              body = body_s4, exports = {'SQL'}})

test:do_execsql_test(
    "gh-2579-7",
    [[
        SELECT s4(a, i) FROM t;
    ]], {
        4.8
    })

--
-- Make sure that user-defined aggregate functions with more than one argument
-- cannot work with DISTINCT.
--
test:do_catchsql_test(
    "gh-2579-8",
    [[
        SELECT s4(distinct a, i) FROM t;
    ]], {
        1, "DISTINCT aggregates must have exactly one argument"
    })

-- Make sure user-defined aggregate functions are not available in Lua.
test:do_test(
    "gh-2579-9",
    function()
        local def = {aggregate = 'group', returns = 'number',
                     param_list = {'integer'}, exports = {'LUA', 'SQL'}}
        local res = {pcall(box.schema.func.create, 'S5', def)}
        return {tostring(res[2])}
    end, {
        "Failed to create function 'S5': aggregate function can only be "..
        "accessed in SQL"
    })

--
-- Make sure user-defined aggregate functions should have both STEP and FINALIZE
-- persistent or non-persistent.
--
test:do_test(
    "gh-2579-10",
    function()
        local body = "function(x) return x / 1000 end"
        local def = {aggregate = 'group', returns = 'number', body = body,
                     param_list = {'integer'}, exports = {'SQL'}}
        local res = {pcall(box.schema.func.create, 'S6', def)}
        return {tostring(res[2])}
    end, {
        "Failed to create function 'S6': step or finalize of aggregate "..
        "function is undefined"
    })

--
-- Make sure body of user-defined aggregate function should have exactly two
-- fields: "step" and "finalize".
--
test:do_test(
    "gh-2579-11",
    function()
        local body = {step = "function(x) return x / 1000 end"}
        local def = {aggregate = 'group', returns = 'number', body = body,
                     param_list = {'integer'}, exports = {'SQL'}}
        local res = {pcall(box.schema.func.create, 'S7', def)}
        return {tostring(res[2])}
    end, {
        "Failed to create function 'S7': body of aggregate function should "..
        "be map that contains exactly two string fields: 'step' and 'finalize'"
    })

test:do_test(
    "gh-2579-12",
    function()
        local body = {finalize = "function(x) return x / 1000 end"}
        local def = {aggregate = 'group', returns = 'number', body = body,
                     param_list = {'integer'}, exports = {'SQL'}}
        local res = {pcall(box.schema.func.create, 'S8', def)}
        return {tostring(res[2])}
    end, {
        "Failed to create function 'S8': body of aggregate function should "..
        "be map that contains exactly two string fields: 'step' and 'finalize'"
    })

test:do_test(
    "gh-2579-13",
    function()
        local body = {
            step = [[function(x, y, z)
                if x == nil then
                    x = {sum = 0, count = 0}
                end
                x.sum = x.sum + y + z
                x.count = x.count + 1
                return x
            end]],
            finalize = [[function(x)
                return x.sum / x.count
            end]],
            something = 0
        }
        local def = {aggregate = 'group', returns = 'number', body = body,
                     param_list = {'integer'}, exports = {'SQL'}}
        local res = {pcall(box.schema.func.create, 'S9', def)}
        return {tostring(res[2])}
    end, {
        "Failed to create function 'S9': body of aggregate function should "..
        "be map that contains exactly two string fields: 'step' and 'finalize'"
    })

--
-- Make sure that user-defined aggregate functions that are throwing an error
-- are working correctly.
--
local body_s10 = {
    step = [[function(x) error("some error") return 0 end]],
    finalize = [[function(x) return 0 end]]
}

box.schema.func.create('S10', {aggregate = 'group', returns = 'number',
                              body = body_s10, exports = {'SQL'}})

test:do_catchsql_test(
    "gh-2579-14",
    [[
        SELECT s10();
    ]], {
        1, '[string "return function(x) error("some error") return..."]:1: '..
           'some error'
    })

local body_s11 = {
    step = [[function(x) return 0 end]],
    finalize = [[function(x) error("another error") return 0 end]]
}

box.schema.func.create('S11', {aggregate = 'group', returns = 'number',
                              body = body_s11, exports = {'SQL'}})

test:do_catchsql_test(
    "gh-2579-15",
    [[
        SELECT s11();
    ]], {
        1, '[string "return function(x) error("another error") ret..."]:1: '..
           'another error'
    })

box.space._func.index[2]:delete("S1")
box.space._func.index[2]:delete("S2")
box.space._func.index[2]:delete("gh-2579-custom-aggregate.S3")
box.space._func.index[2]:delete("S4")
box.space._func.index[2]:delete("S10")
box.space._func.index[2]:delete("S11")
box.space.T:drop()

test:finish_test()
