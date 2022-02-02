local t = require('luatest')
local net = require('net.box')
local cluster = require('test.luatest_helpers.cluster')
local helpers = require('test.luatest_helpers')
local fiber = require('fiber')

local g = t.group('gh_6260')

g.before_test('test_box_status_event', function(cg)
    cg.cluster = cluster:new({})

    local box_cfg = {
        read_only = false
    }

    cg.master = cg.cluster:build_server({alias = 'master', box_cfg = box_cfg})
    cg.cluster:add_server(cg.master)
    cg.cluster:start()
end)


g.after_test('test_box_status_event', function(cg)
    cg.cluster.servers = nil
    cg.cluster:drop()
end)


g.test_box_status_event= function(cg)
    local c = net.connect(cg.master.net_box_uri)

    local result = {}
    local result_no = 0
    local watcher = c:watch('box.status',
                            function(name, state)
				assert(name == 'box.status')
                                result = state
                                result_no = result_no + 1
                            end)

    -- initial state should arrive
    while result_no < 1 do fiber.sleep(0.000001) end
    t.assert_equals(result, {is_ro = false, is_ro_cfg = false, status = 'running'})

    -- test orphan status appearance
    cg.master:eval(([[
        box.cfg{
            replication = {
                "%s",
                "%s"
            },
            replication_connect_timeout = 0.001,
	    replication_timeout = 0.001,
        }
    ]]):format(helpers.instance_uri('master'),
               helpers.instance_uri('replica')))
    -- here we have 2 notifications: entering ro when can't connect
    -- to master and the second one when going orphan
    while result_no < 3 do fiber.sleep(0.000001) end
    t.assert_equals(result, {is_ro = true, is_ro_cfg = false, status = 'orphan'})

    -- test ro_cfg appearance
    cg.master:eval([[
        box.cfg{
            replication = {},
            read_only = true,
        }
    ]])
    while result_no < 4 do fiber.sleep(0.000001) end
    t.assert_equals(result, {is_ro = true, is_ro_cfg = true, status = 'running'})

    -- reset to rw
    cg.master:eval([[
        box.cfg{
            read_only = false,
        }
    ]])
    while result_no < 5 do fiber.sleep(0.000001) end
    t.assert_equals(result, {is_ro = false, is_ro_cfg = false, status = 'running'})

    -- turning manual election mode puts into ro
    cg.master:eval([[
        box.cfg{
            election_mode = 'manual',
        }
    ]])
    while result_no < 6 do fiber.sleep(0.000001) end
    t.assert_equals(result, {is_ro = true, is_ro_cfg = false, status = 'running'})

    -- promotion should turn rm
    cg.master:eval([[
        box.ctl.promote()
    ]])
    while result_no < 7 do fiber.sleep(0.000001) end
    t.assert_equals(result, {is_ro = false, is_ro_cfg = false, status = 'running'})

    watcher:unregister()
    c:close()
end

