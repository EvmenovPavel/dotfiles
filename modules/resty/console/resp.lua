-- the REdis Serialization Protocol implementation
-- stealing from https://github.com/fffonion/lua-resty-shdict-server

local tonumber     = tonumber
local type         = type
local sub          = string.sub
local byte         = string.byte
local table_concat = table.concat
local ngx_log      = ngx.log

local ins          = require 'inspect'

local ok, new_tab  = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function()
        return {}
    end
end

local _M    = new_tab(0, 54)

_M._VERSION = '0.02'

local CRLF  = "\r\n"

local mt    = { __index = _M }

function _M.new(handler)
    return setmetatable({ handler = handler }, mt)
end

local function _parse_redis_req(line, sock)
    -- parse RESP protocol request with a preread line and the request socket
    local err
    if not line then
        line, err = sock:receive()
        if not line then
            return nil, err
        end
    end

    -- taken from lua-resty-redis._read_reply
    local prefix = byte(line)
    -- print('>prefix:', prefix, ' line:', line)

    if prefix == 36 then
        -- char '$'
        -- print("bulk reply")

        local size = tonumber(sub(line, 2))
        if size < 0 then
            return nil
        end

        local data
        data, err = sock:receive(size)
        -- print('>data:', data or err)
        if not data then
            -- if err == "timeout" then
            -- end
            return nil, err
        end

        local dummy
        dummy, err = sock:receive(2) -- ignore CRLF
        if not dummy then
            return nil, err
        end

        return data

    elseif prefix == 43 then
        -- char '+'
        -- print("status reply")

        return sub(line, 2)

    elseif prefix == 42 then
        -- char '*'
        local n = tonumber(sub(line, 2))

        -- print("multi-bulk reply: ", n)
        if n < 0 then
            return
        end

        local cmd
        local vals  = new_tab(n - 1, 0)
        local nvals = 0
        for _ = 1, n do
            local res
            res, err = _parse_redis_req(nil, sock)
            if res then
                if cmd == nil then
                    cmd = res
                else
                    nvals       = nvals + 1
                    vals[nvals] = res
                end

            elseif res == nil then
                return nil, err

            else
                -- be a valid redis error value
                if cmd == nil then
                    cmd = res
                else
                    nvals       = nvals + 1
                    vals[nvals] = { false, err }
                end
            end
        end

        return cmd, vals

    elseif prefix == 58 then
        -- char ':'
        -- print("integer reply")
        return tonumber(sub(line, 2))

    elseif prefix == 45 then
        -- char '-'
        -- print("error reply: ", n)

        return false, sub(line, 2)

    else
        -- when `line` is an empty string, `prefix` will be equal to nil.
        return nil, "unknown prefix: \"" .. tostring(prefix) .. "\""
    end
end

local function _serialize_redis(data)
    if data == nil then
        return "$-1" .. CRLF
    elseif type(data) == 'string' then
        return "+" .. data .. CRLF
    elseif type(data) == 'number' then
        return ":" .. data .. CRLF
    elseif type(data) == 'table' then
        local r = { "*" .. #data }
        -- only iterate the array part
        for _, v in ipairs(data) do
            if type(v) == 'string' then
                r[#r + 1] = "$" .. #v
                r[#r + 1] = v
            elseif type(v) == 'number' then
                r[#r + 1] = ":" .. v
            elseif type(v) == 'table' then
                r[#r + 1] = _serialize_redis(v)
            elseif v == nil then
                r[#r + 1] = "$-1"
            else
                ngx_log(ngx.DEBUG, "value ", v, " (type: ", type(v), ") can't be serialized in an array")
            end
        end
        -- add trailling CRLF
        r[#r + 1] = ""
        return table_concat(r, CRLF)
    else
        return "-ERR Type '" .. type(data) .. "' can't be serialized using RESP" .. CRLF
    end
end

local function output_redis(ret)
    if ret.err then
        return "-" .. ret.err .. CRLF
    end

    return _serialize_redis(ret.msg)
end

-- the param of 'sock' to make test easier
function _M.serve(self, sock)
    sock = sock or assert(ngx.req.socket(true))
    local line, prefix, err
    while true do
        local typ, args
        -- read a line
        line, err = sock:receive()
        -- print('recv:', line or err)
        if not line or #line == 0 then
            if err ~= "timeout" then
                return
            end
        else
            prefix = byte(line)
            if prefix == 42 then
                -- char '*'
                typ, args = _parse_redis_req(line, sock)
                if typ == nil then
                    sock:send(output_redis({ ["err"] = args }))
                end
            end

            -- print('type:', typ, ' args:', ins(args))
            if not typ then
                sock:send("Invalid argument(s)", CRLF)
            else
                local ret = self.handler(typ, args)
                if ret then
                    ngx.log(ngx.DEBUG, ins(ret.msg))
                    sock:send(output_redis(ret))
                else
                    return
                end
            end
        end
    end

end

return _M
