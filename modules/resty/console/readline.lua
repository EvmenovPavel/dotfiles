#!/usr/bin/env lua

-- local ins = require 'inspect'
local history_file = os.getenv('HOME') .. '/.repl-history'
local ffi          = require 'ffi'

ffi.cdef(require 'resty.console.readline_h')

local function load_readline()
    local ok, clib
    -- for linux with readline 6.x, 7.x, and macos
    for _, suffix in ipairs({ '.so.6', '.so.7', '' }) do
        pcall(ffi.load, 'libhistory' .. suffix)
        ok, clib = pcall(ffi.load, 'libreadline' .. suffix)
        if ok then
            return clib
        end
    end

    print(clib)     -- this is actually error string
    return ffi.C.exit(2)
end

local clib = load_readline()
clib.rl_initialize()
clib.read_history(history_file)      -- read history from file

-- from signal.h:
local SIGINT         = 2
local SIG_ERR        = -1

local puts           = function(text)
    text = tostring(text or '') .. '\n'
    return clib.fwrite(text, #text, 1, clib.rl_outstream)
end

local add_to_history = function(text, save)
    clib.add_history(text)
    if save then
        clib.write_history(history_file)
    end
end

local function set_completion_func(func)
    function clib.rl_attempted_completion_function(word)
        local prefix      = ffi.string(word)

        local ok, matches = pcall(func, prefix)
        if not ok then
            return nil
        end

        -- if matches is an rl_completion_entry_function empty array,
        -- tell readline to not call default completion (file)
        clib.rl_attempted_completion_over = 1
        pcall(function()
            clib.rl_completion_suppress_append = 1
        end)

        -- translate matches table to C strings
        -- (there is probably more efficient ways to do it)
        local ret = clib.rl_completion_matches(word, function(_, i)
            local match = matches[i + 1]
            --print(i, match)

            if match then
                -- readline will free the C string by itself, so create copies of them
                local buf = ffi.C.malloc(#match + 1)
                ffi.copy(buf, match, #match + 1)
                return buf
            else
                return ffi.new('void*', nil)
            end
        end)
        return ret
    end
end

local sigint_count = 0
local function sigint_handler()
    -- status
    puts()

    if clib.rl_end == 0 then
        sigint_count = sigint_count + 1
        if sigint_count == 1 then
            puts('Press ^C once again to exit')
        else
            return ffi.C.exit(1)
        end
    else
        sigint_count = 0
        clib.rl_replace_line("", 0)
    end

    clib.rl_on_new_line()
    clib.rl_redisplay();
end

assert(SIG_ERR ~= ffi.C.signal(SIGINT, sigint_handler))

local readline = function(...)
    local input  = clib.readline(...)
    sigint_count = 0

    local line
    if input ~= nil then
        line = ffi.string(input)
        ffi.C.free(input)
    end

    return line
end

local _M       = setmetatable({
                                  puts                = puts,
                                  set_completion_func = set_completion_func,
                                  add_to_history      = add_to_history,
                              }, { __call = function(_, ...)
    return readline(...)
end })

return _M
