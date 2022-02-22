#!/usr/bin/env luajit

---
--- Created by nickr.
--- DateTime: 1/7/19 5:15 PM
---

local ffi = require 'ffi'
local hiredis = require 'hiredis'
local readline = require 'resty.console.readline'
local consts = require 'resty.console.consts'
local utils = require 'resty.console.utils'
local HTTP_LINE = 'GET /console\r\n'

-- local ins = require "inspect"


local args = utils.parse_args()
local HOST, PORT = utils.parse_endpoint(args.endpoint)
-- print(ins(args))

ffi.cdef [[
    /* lua-hiredis.c */
    typedef struct redisReader redisReader;
    typedef struct redisContext {
        int err; /* Error flags, 0 when there is no error */
        char errstr[128]; /* String representation of error when applicable */
        int fd;
        int flags;
        char *obuf; /* Write buffer */
        redisReader *reader; /* Protocol reader */
    } redisContext;

    typedef struct luahiredis_Connection {
        redisContext * pContext;
    } luahiredis_Connection;

    /* stdio.h */
    size_t write(int fd, const void *buf, size_t nbyte);
]]

local function prompt_line(rclient, line_count)
    local context = rclient:command(consts.REPL_TYPE_CONTEXT)
    -- local context = rclient:command(consts.REPL_TYPE_COMMAND)

    if context then
        return '[' .. line_count .. '] ' .. context.name  .. '> '
    else
        return nil
    end
end

local function log(text)
    if not args.quiet then
        readline.puts(text)
    end
end

local main = function()

    local rclient = hiredis.connect(HOST, PORT)
    if not rclient then
        print('connect to ' .. HOST .. ':' .. PORT .. ': Connection refused')
        return
    end

    log('Connected to ' .. HOST .. (PORT and ':' .. PORT or ''))

    -- allow the connection to land on an HTTP handler
    local conn_ctx = ffi.cast('luahiredis_Connection *', rclient).pContext
    ffi.C.write(conn_ctx.fd, HTTP_LINE, #HTTP_LINE)

    if args.chunk or args.file then
        local code = args.chunk or io.input(args.file):read('*a')
        local output = rclient:command(consts.REPL_TYPE_COMMAND, code)
        if output then
            readline.puts('=> ' .. output.name)
        end

        if not args.interactive then
            return output.type == consts.REDIS_REPLY_ERROR
        end
    end

    readline.set_completion_func(function(word)
        local matches = rclient:command(consts.REPL_TYPE_AUTOCOMP, word)
        return matches
    end)

    local line_count = 1
    while true do
        local prompt = prompt_line(rclient, line_count)
        if not prompt then
            break
        end

        local input = readline(prompt)
        -- print('input:', ins(input))

        if input then
            if #input > 0 then
                line_count = line_count + 1
                local output = rclient:command(consts.REPL_TYPE_COMMAND, input)
                if output then
                    readline.puts('=> ' .. output.name)
                else
                    break
                end

                if output and output.type then
                    readline.add_to_history(input, output.type ~= consts.REDIS_REPLY_ERROR)
                end
            end
        else
            readline.puts('')
            break
        end
    end

    log('Connection to '.. HOST .. ( PORT and ':' .. PORT or '') .. ' closed')
end

main()




















--