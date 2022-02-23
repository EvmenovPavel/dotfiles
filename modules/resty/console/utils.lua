---
--- Created by nickr.
--- DateTime: 1/8/19 9:19 PM
---

function string:split(sep)
    local tokens  = {}
    local pattern = string.format("([^%s]+)", sep or ':')
    self:gsub(pattern, function(c)
        table.insert(tokens, c)
    end)
    return tokens
end

local function safe_match(str, re)
    local ok, res = pcall(function()
        return string.match(str, re)
    end)

    return ok and res
end

local function self_path()
    local path = debug.getinfo(1).source
    -- trim the leading @ and the last component (file part)
    return path:gsub('^"?@(.*)/[^/]+$', '%1')
end

local function parse_endpoint(arg)
    -- unix socket
    if string.match(arg, '^/') then
        return arg
    end

    local host, port
    local pos = arg:find(':', 1, true)
    if pos then
        host = arg:sub(1, pos - 1)
        port = arg:sub(pos + 1)
    else
        host = arg
    end
    return host or 'localhost', port or 8000
end

local function parse_args()
    local argparse = require "argparse"
    local parser   = argparse("resty-cli", "Interactive console (REPL) for Openresty" ..
            " to inspect Lua VM internals, to run lua code, to invoke functions and more")
    parser:argument("endpoint", "host:port to connect to", "localhost:8000")
    parser:option("-e --chunk", "chunk of lua code to run on backend")
    parser:option("-f --file", "lua file to run on backend")
    parser:flag("-i", "run in interactive mode"):target('interactive')
    parser:flag("-q --quiet", "quiet mode, no banners or connection status (default: false)", false)
    return parser:parse()
end

return {
    parse_args     = parse_args,
    parse_endpoint = parse_endpoint,
    self_path      = self_path,
    safe_match     = safe_match
}