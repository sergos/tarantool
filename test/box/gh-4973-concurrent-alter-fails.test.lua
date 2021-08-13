test_run = require('test_run')
inspector = test_run.new()
fiber = require('fiber')

-- Create table with enough tuples to make primary index alter in background.
s = box.schema.space.create('test', {engine = 'memtx'})
i = s:create_index('pk',  {type='tree', parts={{1, 'uint'}}})
for i = 1, 6000 do s:replace{i, i, "valid"} end

started = false

inspector:cmd("setopt delimiter ';'");

function joinable(fib)
    fib:set_joinable(true)
    return fib
end;

-- Wait for fiber yield during altering of primary index and then replace some tuples.
function disturb()
    while not started do fiber.sleep(0) end
    for i = 1, 100 do
        s:replace{i, i, "new tuple must be referenced by primary key"}
    end
end;

-- Alter primary index in background.
-- If primary index will not be altered in background, test will not be passed
-- because it will run out of time (disturber:join() will wait forever).
function create()
    started = true
    i:alter({parts={{field = 2, type = 'unsigned'}}})
    started = false
end;

inspector:cmd("setopt delimiter ''");

disturber = joinable(fiber.new(disturb))
creator = joinable(fiber.new(create))

disturber:join()
creator:join()

-- If some tuples are not referenced, garbage collector will delete them
-- and we will catch segmentation fault on s:drop().
collectgarbage("collect")
started = nil
s:drop()
