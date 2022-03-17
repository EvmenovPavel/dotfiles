local llthreads   = require("llthreads")

local thread_code = [[
	-- print thread's parameter.
	print("CHILD: received params:", ...)
	-- return all thread's parameters back to the parent thread.
	return ...
]]

-- create detached child thread.
local thread      = llthreads.new(thread_code, "number:", 1234, "nil:", nil, "bool:", true)
-- start non-joinable detached child thread.
assert(thread:start(true))
-- Use a detatched child thread when you don't care when the child finishes.

-- create child thread.
local thread = llthreads.new(thread_code, "number:", 1234, "nil:", nil, "bool:", true)
-- start joinable child thread.
assert(thread:start())
-- Warning: If you don't call thread:join() on a joinable child thread, it will be called
-- by the garbage collector, which may cause random pauses/freeze of the parent thread.
print("PARENT: child returned: ", thread:join())

local socket = require "socket"
socket.sleep(2) -- give detached thread some time to run.