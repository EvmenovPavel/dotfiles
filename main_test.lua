local threads = require 'threads'

local nthread = 4
local njob    = 10
local msg     = "hello from a satellite thread"

--local pool      = threads.Threads(
--        nthread
--function(threadid)
--print('starting a new thread/state number ' .. threadid)
--gmsg = msg -- get it the msg upvalue and store it in thread state
--end
--)

--local jobdone = 0
--
--print("njob", njob)

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

--pool:synchronize()

--print(string.format('%d jobs done', jobdone))

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

local scripts  = {}

scripts.i3lock = [[ #!/bin/sh

BLANK='#00000000'
CLEAR='#ffffff22'
DEFAULT='#ff00ffcc'
TEXT='#ee00eeee'
WRONG='#880000bb'
VERIFYING='#bb00bbbb'

i3lock \
--insidever-color=$CLEAR     \
--ringver-color=$VERIFYING   \
\
--insidewrong-color=$CLEAR   \
--ringwrong-color=$WRONG     \
\
--inside-color=$BLANK        \
--ring-color=$DEFAULT        \
--line-color=$BLANK          \
--separator-color=$DEFAULT   \
\
--verif-color=$TEXT          \
--wrong-color=$TEXT          \
--time-color=$TEXT           \
--date-color=$TEXT           \
--layout-color=$TEXT         \
--keyhl-color=$WRONG         \
--bshl-color=$WRONG          \
\
--screen 1                   \
--blur 5                     \
--clock                      \
--indicator                  \
--time-str="%H:%M:%S"        \
--date-str="%A, %Y-%m-%d"       \
--keylayout 1]]

print(scripts.i3lock)