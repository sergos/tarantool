#!/usr/bin/env tarantool
local test = require("sqltester")
test:plan(2)

box.cfg{listen = os.getenv('LISTEN')}
local cn = require('net.box').connect(box.cfg.listen)

test:do_test(
    "gh-6766-1",
    function()
        local val = {require('decimal').new(1.5)}
        local res = cn:execute([[SELECT typeof(?);]], val)
        return {res.rows[1][1]}
    end, {
        'decimal'
    })

test:do_test(
    "gh-6766-2",
    function()
        local val = {require('uuid').new()}
        local res = cn:execute([[SELECT typeof(?);]], val)
        return {res.rows[1][1]}
    end, {
        'uuid'
    })

cn:close()

test:finish_test()
