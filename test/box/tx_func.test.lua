env = require('test_run')
test_run = env.new()
test_run:cmd("create server tx_man with script='box/tx_man.lua'")
test_run:cmd("start server tx_man")
test_run:cmd("switch tx_man")


txn_proxy = require('txn_proxy')
tx1 = txn_proxy.new()
tx2 = txn_proxy.new()

id = 666
function setmap(tab) return setmetatable(tab, { __serialize = 'map' }) end

------------------- INSERT + DELETE + INSERT + COMMIT -------------------------------

tx1:begin()
_ = tx1("box.space._func:insert{id, 1, 'f1', 0, 'C', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
_ = tx1("box.space._func:delete({id})")
_ = tx1("box.space._func:insert{id, 1, 'f2', 0, 'LUA', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
tx1:commit()

assert(box.func.f1 == nil)
assert(box.func.f2.language == 'LUA')
assert(box.space._func:get({666})[5] == 'LUA')

------------------- DELETE + INSERT + DELETE + COMMIT -------------------------------

tx1:begin()
_ = tx1("box.space._func:delete({id})")
_ = tx1("box.space._func:insert{id, 1, 'f1', 0, 'C', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
_ = tx1("box.space._func:delete({id})")
tx1:commit()

assert(box.func.f2 == nil)
assert(box.func.f1 == nil)
assert(box.space._func:get({666}) == nil)

------------------- INSERT + DELETE + COMMIT -------------------------------

tx1:begin()
_ = tx1("box.space._func:insert{id, 1, 'f1', 0, 'C', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
_ = tx1("box.space._func:delete({id})")
tx1:commit()

assert(box.func.f1 == nil)
assert(box.space._func:get({666}) == nil)

------------------- DELETE + INSERT + COMMIT -------------------------------

_ = box.space._func:insert{id, 1, 'f2', 0, 'LUA', '', 'function', {}, 'any', 'none', 'none', false, false, true, {"LUA"}, setmap({}), '', '', ''}

tx1:begin()
_ = tx1("box.space._func:delete({id})")
_ = tx1("box.space._func:insert{id, 1, 'f2', 0, 'C', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
tx1:commit()

assert(box.func.f1 == nil)
assert(box.func.f2.language == 'C')
assert(box.space._func:get({666})[5] == 'C')

------------------- DELETE + ROLLBACK -----------------------------------------------

tx1:begin()
_ = tx1("box.space._func:delete{id}")
tx1:rollback()

assert(box.func.f2.language == 'C')
assert(box.space._func:get({666})[5] == 'C')
_ = box.space._func:delete{id}

------------------- INSERT + ROLLBACK -----------------------------------------------

tx1:begin()
_ = tx1("box.space._func:insert{id, 1, 'f1', 0, 'C', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
tx1:rollback()

assert(box.func.f1 == nil)
assert(box.space._func:get({666}) == nil)

------------------- INSERT + DELETE + ROLLBACK -------------------------------

tx1:begin()
_ = tx1("box.space._func:insert{id, 1, 'f1', 0, 'C', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
_ = tx1("box.space._func:delete({id})")
tx1:rollback()

assert(box.func.f1 == nil)
assert(box.space._func:get({666}) == nil)

------------------- DELETE + INSERT + ROLLBACK -------------------------------

_ = box.space._func:insert{id, 1, 'f2', 0, 'LUA', '', 'function', {}, 'any', 'none', 'none', false, false, true, {"LUA"}, setmap({}), '', '', ''}

tx1:begin()
_ = tx1("box.space._func:delete({id})")
_ = tx1("box.space._func:insert{id, 1, 'f1', 0, 'C', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
tx1:rollback()

assert(box.func.f1 == nil)
assert(box.func.f2.language == 'LUA')
assert(box.space._func:get({666})[5] == 'LUA')

_ = box.space._func:delete{id}

------------------- INSERT + DELETE + INSERT + ROLLBACK -----------------------------

tx1:begin()
_ = tx1("box.space._func:insert{id, 1, 'f1', 0, 'C', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
_ = tx1("box.space._func:delete({id})")
_ = tx1("box.space._func:insert{id, 1, 'f2', 0, 'LUA', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
tx1:rollback()

assert(box.func.f1 == nil)
assert(box.func.f2 == nil)
assert(box.space._func:get({666}) == nil)

------------------- DELETE + INSERT + DELETE + ROLLBACK -----------------------------

_ = box.space._func:insert{id, 1, 'f1', 0, 'C', '', 'function', {}, 'any', 'none', 'none', false, false, true, {"LUA"}, setmap({}), '', '', ''}

tx1:begin()
_ = tx1("box.space._func:delete({id})")
_ = tx1("box.space._func:insert{id, 1, 'f2', 0, 'LUA', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
_ = tx1("box.space._func:delete({id})")
tx1:rollback()

assert(box.func.f1.language == 'C')
assert(box.func.f2 == nil)
assert(box.space._func:get({666})[5] == 'C')

_ = box.space._func:delete{id}

tx1:begin()
tx2:begin()

_ = tx1("box.space._func:insert{id, 1, 'f1', 0, 'C', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
_ = tx2("box.space._func:insert{id, 1, 'f1', 0, 'LUA', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")

tx1:rollback()
tx2:commit()

assert(box.func.f1.language == 'LUA')
assert(box.space._func:get({666})[5] == 'LUA')

_ = box.space._func:delete({666})

tx1:begin()
tx2:begin()

_ = tx1("box.space._func:insert{id, 1, 'f1', 0, 'C', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
_ = tx2("box.space._func:insert{id+1, 1, 'f1', 0, 'LUA', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")

tx1:commit()
tx2:commit()

assert(box.func.f1.language == 'C')
assert(box.space._func:get({666})[5] == 'C')

_ = box.space._func:delete({666})

tx1:begin()
tx2:begin()

_ = tx1("box.space._func:replace{id, 1, 'f1', 0, 'C', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
_ = tx2("box.space._func:replace{id+1, 1, 'f1', 0, 'LUA', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")

tx1:commit()
tx2:commit()

assert(box.func.f1.language == 'C')
assert(box.space._func:get({666})[5] == 'C')

_ = box.space._func:delete({666})

tx1:begin()
tx2:begin()

_ = tx1("box.space._func:insert{id, 1, 'f1', 0, 'C', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
_ = tx2("box.space._func:insert{id, 1, 'f1', 0, 'LUA', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
_ = tx1("box.space._func:delete({id})")

tx1:commit()
tx2:commit()

assert(box.func.f1 == nil)
assert(box.space._func:get({666}) == nil)

tx1:begin()
tx2:begin()

_ = tx1("box.space._func:insert{id, 1, 'f1', 0, 'C', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
_ = tx2("box.space._func:insert{id, 1, 'f1', 0, 'LUA', '', 'function', {}, 'any', 'none', 'none', false, false, true, {\"LUA\"}, setmap({}), '', '', ''}")
_ = tx1("box.space._func:delete({id})")

tx1:rollback()
tx2:commit()

test_run:cmd("switch default")
test_run:cmd("stop server tx_man")
test_run:cmd("cleanup server tx_man")
