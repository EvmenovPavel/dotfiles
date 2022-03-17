local threads     = {}

local C           = require("libthreads")

threads.Thread    = C.Thread
threads.Mutex     = C.Mutex
threads.Condition = C.Condition
threads.Threads   = require('lib.threads.threads')
threads.safe      = require('lib.threads.safe')

-- only for backward compatibility (boo)
setmetatable(threads, getmetatable(threads.Threads))

--return threads
