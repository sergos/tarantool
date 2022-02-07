local t = require('luatest')
local net = require('net.box')
local cluster = require('test.luatest_helpers.cluster')
local helpers = require('test.luatest_helpers')
local fiber = require('fiber')
local server = require('test.luatest_helpers.server')

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


g.before_test('test_box_election_event', function(cg)

    cg.cluster = cluster:new({})

    local box_cfg = {
        replication = {
                        helpers.instance_uri('instance_', 1);
                        helpers.instance_uri('instance_', 2);
                        helpers.instance_uri('instance_', 3);
        },
        replication_connect_quorum = 0,
        election_mode = 'off',
        replication_synchro_quorum = 2,
        replication_synchro_timeout = 1,
        replication_timeout = 0.25,
        election_timeout = 0.25,
    }

    cg.instance_1 = cg.cluster:build_server(
        {alias = 'instance_1', box_cfg = box_cfg})

    cg.instance_2 = cg.cluster:build_server(
        {alias = 'instance_2', box_cfg = box_cfg})

    cg.instance_3 = cg.cluster:build_server(
        {alias = 'instance_3', box_cfg = box_cfg})

    cg.cluster:add_server(cg.instance_1)
    cg.cluster:add_server(cg.instance_2)
    cg.cluster:add_server(cg.instance_3)
    cg.cluster:start({cg.instance_1, cg.instance_2, cg.instance_3})
end)


g.after_test('test_box_election_event', function(cg)
    cg.cluster.servers = nil
    cg.cluster:drop({cg.instance_1, cg.instance_2, cg.instance_3})
end)


g.test_box_election_event= function(cg)
    local c = {}
    c[1] = net.connect(cg.instance_1.net_box_uri)
    c[2] = net.connect(cg.instance_2.net_box_uri)
    c[3] = net.connect(cg.instance_3.net_box_uri)

    local res = {}
    local res_n = {0, 0, 0}

    for i = 1, 3 do
        c[i]:watch('box.election',
                   function(n, s)
                       t.assert_equals(n, 'box.election')
                       res[i] = s
                       res_n[i] = res_n[i] + 1
                   end)
    end
    while res_n[1] + res_n[2] + res_n[3] < 3 do fiber.sleep(0.00001) end

    -- verify all instances are in the same state
    t.assert_equals(res[1], res[2])
    t.assert_equals(res[1], res[3])

    -- wait for elections to complete, verify leader is the instance_1
    -- trying to avoid the exact number of term - it can vary
    local instance1_id = cg.instance_1:eval("return box.info.id")

    cg.instance_1:eval("box.cfg{election_mode='candidate'}")
    cg.instance_2:eval("box.cfg{election_mode='voter'}")
    cg.instance_3:eval("box.cfg{election_mode='voter'}")

    cg.instance_1:wait_election_leader_found()
    cg.instance_2:wait_election_leader_found()
    cg.instance_3:wait_election_leader_found()

    t.assert_equals(res[1].leader, instance1_id)
    t.assert_equals(res[1].is_ro, false)
    t.assert_equals(res[1].role, 'leader')
    t.assert_equals(res[2].leader, instance1_id)
    t.assert_equals(res[2].is_ro, true)
    t.assert_equals(res[2].role, 'follower')
    t.assert_equals(res[3].leader, instance1_id)
    t.assert_equals(res[3].is_ro, true)
    t.assert_equals(res[3].role, 'follower')
    t.assert_equals(res[1].term, res[2].term)
    t.assert_equals(res[1].term, res[3].term)

    -- check the stepping down is working
    res_n = {0, 0, 0}
    cg.instance_1:eval("box.cfg{election_mode='voter'}")
    while res_n[1] + res_n[2] + res_n[3] < 3 do fiber.sleep(0.00001) end

    local expected = {is_ro = true, role = 'follower', term = res[1].term, leader = 0}
    t.assert_equals(res[1], expected)
    t.assert_equals(res[2], expected)
    t.assert_equals(res[3], expected)

    c[1]:close()
    c[2]:close()
    c[3]:close()
end

g.before_test('test_box_schema', function(cg)
    g.server = server:new({alias = 'master'})
end)

g.after_test('test_box_schema', function(cg)
    g.server:cleanup()
end)

g.test_box_schema = function()
    g.server:start({wait_for_readiness = true})
    local c = net.connect(g.server.net_box_uri)
    local version = 0
    local version_n = 0
    c:watch('box.schema', function(n, s)
	                      t.assert_equals(n, 'box.schema')
                              version = s.version
			      version_n = version_n + 1
                          end)

    g.server:eval("box.schema.create_space('p')")
    while version_n < 1 do fiber.sleep(0.001) end
    -- virst version change, use it as initial value
    local init_version = version

    version_n = 0
    g.server:eval("box.space.p:create_index('i')")
    while version_n < 1 do fiber.sleep(0.001) end
    t.assert_equals(version, init_version + 1)

    version_n = 0
    g.server:eval("box.space.p:drop()")
    while version_n < 1 do fiber.sleep(0.001) end
    -- there'll be 2 changes - index and space
    t.assert_equals(version, init_version + 3)

    c:close()
end
