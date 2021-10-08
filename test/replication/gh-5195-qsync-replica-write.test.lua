test_run = require('test_run').new()
fiber = require('fiber')
engine = test_run:get_cfg('engine')
old_synchro_quorum = box.cfg.replication_synchro_quorum
old_synchro_timeout = box.cfg.replication_synchro_timeout

box.schema.user.grant('guest', 'super')

test_run:cmd('create server replica with rpl_master=default,\
              script="replication/replica.lua"')
test_run:cmd('start server replica with wait=True, wait_load=True')

--
-- gh-5195: WAL write on a read-write replica should not crash master. Limbo
-- should be ready that ACKs can contain the same LSN from the same replica
-- multiple times.
--
_ = box.schema.space.create('sync', {engine = engine, is_sync = true})
_ = box.space.sync:create_index('pk')
box.ctl.promote()

box.cfg{replication_synchro_timeout = 1000, replication_synchro_quorum = 3}
lsn = box.info.lsn
ok, err = nil
f = fiber.create(function()                                                     \
    ok, err = pcall(box.space.sync.insert, box.space.sync, {2})                 \
end)
lsn = lsn + 1
test_run:wait_cond(function() return box.info.lsn == lsn end)

test_run:switch('replica')
test_run:wait_lsn('replica', 'default')
-- Normal DML is blocked - the limbo is not empty and does not belong to the
-- replica. But promote also does a WAL write, and propagates LSN
-- of the instance.
box.cfg{replication_synchro_timeout = 0.001, replication_synchro_quorum = 1}
box.ctl.promote()

test_run:switch('default')
-- Wait second ACK receipt.
replica_id = test_run:get_server_id('replica')
replica_lsn = test_run:get_lsn('replica', replica_id)
test_run:wait_downstream(replica_id, {status='follow'})
test_run:wait_cond(function()                                                   \
        local vclock = box.info.replication[replica_id].downstream.vclock       \
        return (vclock and vclock[replica_id] and                               \
                vclock[replica_id] >= replica_lsn)                              \
    end) or require('log').error(box.info)

box.cfg{replication_synchro_quorum = 2}
test_run:wait_cond(function() return f:status() == 'dead' end)
ok, err
box.space.sync:select{}

test_run:switch('replica')
box.space.sync:select{}

test_run:switch('default')

test_run:cmd('stop server replica')
test_run:cmd('delete server replica')

box.ctl.demote()
box.space.sync:drop()
box.schema.user.revoke('guest', 'super')

box.cfg{                                                                        \
    replication_synchro_quorum = old_synchro_quorum,                            \
    replication_synchro_timeout = old_synchro_timeout,                          \
}
