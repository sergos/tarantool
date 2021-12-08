local t = require('luatest')
local cluster = require('test.luatest_helpers.cluster')
local helpers = require('test.luatest_helpers')

local g = t.group('gh_6260', {{engine = 'memtx'}, {engine = 'vinyl'}})

g.before_each(function(cg)
    local engine = cg.params.engine

    cg.cluster = cluster:new({})

    local box_cfg = {
        replication         = {
            helpers.instance_uri('master')
        },
        replication_timeout = 1,
        read_only           = false
    }

    cg.master = cg.cluster:build_server({alias = 'master', engine = engine, box_cfg = box_cfg})
    cg.cluster:add_server(cg.master)
    cg.cluster:start()
end)


g.after_each(function(cg)
    cg.cluster.servers = nil
    cg.cluster:drop()
end)


g.test_box_status_event = function(cg)
    cg.master:eval([[
        i = ''
        box.watch('box.status', function(...) i = {...} end)
    ]])
    t.assert_equals(cg.master:eval("return i"), {"box.status", {is_ro = false, is_ro_cfg = false, status = "running"}})

    cg.master:eval(([[
        box.cfg{
            replication = {
                "%s",
                "%s"
            },
            replication_connect_timeout = 0.001,
        }
    ]]):format(helpers.instance_uri('master'), helpers.instance_uri('replica')))
    t.assert_equals(cg.master:eval("return i"), {"box.status", {is_ro = true, is_ro_cfg = false, status = "orphan"}})

    cg.master:eval(([[
        box.cfg{
            replication = {
                "%s",
            },
        }
    ]]):format(helpers.instance_uri('master')))
    t.assert_equals(cg.master:eval("return i"), {"box.status", {is_ro = false, is_ro_cfg = false, status = "running"}})

    cg.master:eval("box.cfg{read_only = true}")
    t.assert_equals(cg.master:eval("return i"), {"box.status", {is_ro = true, is_ro_cfg = true, status = "running"}})
end
