--local threads = require 'threads'
--
--local nthread = 4
--local njob    = 10
--local msg     = "hello from a satellite thread"
--
--local pool    = threads.Threads(
--        nthread,
--        function(threadid)
--            print('starting a new thread/state number ' .. threadid)
--            gmsg = msg -- get it the msg upvalue and store it in thread state
--        end
--)
--
--local jobdone = 0
--
--print("njob", njob)
--
--for i = 1, njob do
--    print(i)
--
--    pool:addjob(
--            function()
--                print(string.format('%s -- thread ID is %x', gmsg, __threadid))
--                return __threadid
--            end
--    --,
--
--            --function(id)
--            --    print(string.format("task %d finished (ran on thread ID %x)", i, id))
--            --    jobdone = jobdone + 1
--            --end
--    )
--end
--
--pool:synchronize()
--
--print(string.format('%d jobs done', jobdone))
--
--pool:terminate()

--require 'inifile'
--
--local keyboardlayout = require("keyboardlayout")
--
--if ("ru" == keyboardlayout:name()) then
--    print("ru")
--end
--
--print(keyboardlayout:groupname())

local configEnv = {} -- to keep it separate from the global env
local f, err    = loadfile("personal.txt", "t", configEnv)
if f then
    f() -- run the chunk
    -- now configEnv should contain your data
    print("configEnv", configEnv.user4) -- table
else
    print("err", err)
end