#!/usr/bin/env tarantool
local test = require("sqltester")
test:plan(23)

-- Make sure that it is possible to get elements from MAP и ARRAY.
test:do_execsql_test(
    "msgpack-1.1",
    [[
        SELECT [123, 234, 356, 467][2];
    ]], {
        234
    })

test:do_execsql_test(
    "msgpack-1.2",
    [[
        SELECT {'one' : 123, 3 : 'two', '123' : true}[3];
    ]], {
        'two'
    })

test:do_execsql_test(
    "msgpack-1.3",
    [[
        SELECT {'one' : [11, 22, 33], 3 : 'two', '123' : true}['one'][2];
    ]], {
        22
    })

test:do_execsql_test(
    "msgpack-1.4",
    [[
        SELECT {'one' : 123, 3 : 'two', '123' : true}['three'];
    ]], {
        ""
    })

--
-- Make sure that operator [] cannot get elements from values of types other
-- than MAP and ARRAY.
--
test:do_catchsql_test(
    "msgpack-2.1",
    [[
        SELECT 1[1];
    ]], {
        1, "Selecting is only possible from map and array values"
    })

test:do_catchsql_test(
    "msgpack-2.2",
    [[
        SELECT -1[1];
    ]], {
        1, "Selecting is only possible from map and array values"
    })

test:do_catchsql_test(
    "msgpack-2.3",
    [[
        SELECT 1.1[1];
    ]], {
        1, "Selecting is only possible from map and array values"
    })

test:do_catchsql_test(
    "msgpack-2.4",
    [[
        SELECT 1.2e0[1];
    ]], {
        1, "Selecting is only possible from map and array values"
    })

test:do_catchsql_test(
    "msgpack-2.5",
    [[
        SELECT '1'[1];
    ]], {
        1, "Selecting is only possible from map and array values"
    })

test:do_catchsql_test(
    "msgpack-2.6",
    [[
        SELECT x'31'[1];
    ]], {
        1, "Selecting is only possible from map and array values"
    })

test:do_catchsql_test(
    "msgpack-2.7",
    [[
        SELECT uuid()[1];
    ]], {
        1, "Selecting is only possible from map and array values"
    })

test:do_catchsql_test(
    "msgpack-2.8",
    [[
        SELECT true[1];
    ]], {
        1, "Selecting is only possible from map and array values"
    })

test:do_catchsql_test(
    "msgpack-2.9",
    [[
        SELECT CAST(1 AS NUMBER)[1];
    ]], {
        1, "Selecting is only possible from map and array values"
    })

test:do_catchsql_test(
    "msgpack-2.10",
    [[
        SELECT CAST('a' AS STRING)[1];
    ]], {
        1, "Selecting is only possible from map and array values"
    })

test:do_catchsql_test(
    "msgpack-2.11",
    [[
        SELECT NULL[1];
    ]], {
        1, "Selecting is only possible from map and array values"
    })

test:do_catchsql_test(
    "msgpack-2.12",
    [[
        SELECT CAST(NULL AS ANY)[1];
    ]], {
        1, "Selecting is only possible from map and array values"
    })

-- Make sure that the second and the following brackets do not throw type error.
test:do_execsql_test(
    "msgpack-3.1",
    [[
        SELECT [1, 2, 3][1][2];
    ]], {
        ""
    })

test:do_execsql_test(
    "msgpack-3.2",
    [[
        SELECT [1, 2, 3][1][2][3][4][5][6][7];
    ]], {
        ""
    })

test:do_catchsql_test(
    "msgpack-3.3",
    [[
        SELECT ([1, 2, 3][1])[2];
    ]], {
        1, "Type mismatch: can not convert integer(1) to map or array"
    })

-- Make sure that type of result of [] is checked in runtime.
test:do_execsql_test(
    "msgpack-4.1",
    [[
        SELECT [123, 23, 1][2] + 7;
    ]], {
        30
    })

test:do_catchsql_test(
    "msgpack-4.2",
    [[
        SELECT ['a', 2, true][1] + 1;
    ]], {
        1, "Type mismatch: can not convert string('a') to integer, decimal "..
        "or double"
    })

test:do_execsql_test(
    "msgpack-4.3",
    [[
        SELECT {[11, 22, 33][3] : 'asd'};
    ]], {
        {[33] = 'asd'}
    })

-- Built-in functions in this case will use default types of arguments.
test:do_execsql_test(
    "msgpack-4.4",
    [[
        SELECT typeof(ABS([123, 23, 1][1]));
    ]], {
        "decimal"
    })

test:finish_test()
