local resp_module   = require 'resty.console.resp'
local new_binding   = require 'resty.console.binding'.new
local new_completer = require 'resty.console.completer'.new
local consts        = require 'resty.console.consts'
local ngx_log       = ngx.log
local ins           = require 'inspect'

local ok, new_tab   = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function()
        return {}
    end
end

local _M      = {}

local context = function()
    if _G.ngx and _G.ngx.get_phase then
        return 'ngx[' .. _G.ngx.worker.id() .. '].' .. _G.ngx.get_phase()
    else
        return 'lua(main)'
    end
end
_M.context    = context

local function handler(type, arg)
    local ret = new_tab(0, 2)

    assert(#arg < 2, 'only a single string (including whitespaces) allowed')
    arg = arg[1]
    ngx_log(ngx.DEBUG, ins(arg or type))

    if type == consts.REPL_TYPE_COMMAND then
        if arg == '.quit' or arg == '.exit' then
            return
        end

        local res = _M.binding:eval(arg)

        if res.ok then
            ret.msg = res:inspect()
        else
            ret.err = res:inspect()
        end
    elseif type == consts.REPL_TYPE_CONTEXT then
        ret.msg = context()
    elseif type == consts.REPL_TYPE_AUTOCOMP then
        ret.msg = _M.completer:find_matches(arg)
    end

    -- ngx_log(ngx.DEBUG, ins(ret.msg))
    return ret
end
_M.handler = handler

local function start()
    ngx_log(ngx.DEBUG, 'start repl')

    local caller_info = debug.getinfo(2)
    _M.binding        = new_binding(caller_info)
    _M.completer      = new_completer(_M.binding)

    local resp        = resp_module.new(handler)
    resp:serve()

    ngx_log(ngx.DEBUG, 'done')
end

_M.start = start
return _M

