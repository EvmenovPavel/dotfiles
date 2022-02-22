-- lua REPL runtime binding

local _M = {}

local safe_match = require 'resty.console.utils'.safe_match
local ins = require 'inspect'
local InstanceMethods = {}

local _ok, new_tab = pcall(require, "table.new")
if not _ok or type(new_tab) ~= "function" then
    new_tab = function()
        return {}
    end
end

local result_mt = {}
result_mt.__index = result_mt
function result_mt:inspect()
    if not self.ok then
        local err = self.val
        if 'table' == type(err) then
            err = ins(err)
        end
        return 'ERROR: ' .. err
    end

    local value = self.val
    if _G.ngx and (_G.ngx.null == self.val) then
        value = '<ngx.null>'
    elseif 'table' == type(self.val) then
        -- print(ins(self))
        if self.n >= 2 then
            local t = new_tab(self.n, 0)
            local i = 1
            while i <= self.n do
                table.insert(t, ins(self.val[i]))
                i = i + 1
            end
            value = table.concat(t, ', ')
        else
            value = ins(value)
        end
    end

    return tostring(value)
end

local make_result = function(ok, ...)
    local val = {...}
    local n = select('#', ...)
    --ngx.log(ngx.DEBUG, 'res:', inspect(val))
    if n < 2 then
        val = val[1]
    end
    return setmetatable({ ok = ok, val = val, n = n }, result_mt)
end
_M.make_result = make_result

local get_function_index = function(func)
    local caller_index = 1
    local i = caller_index

    while true do
        local info = debug.getinfo(i)
        if not info then
            break
        end

        if info.func == func then
            return i
        end

        i = i + 1
    end
end

local function compile(code)
    if not code then code = '' end

    -- first, try to load function that returns value
    local code_function, err = loadstring('return ' .. code)

    -- if failed, load function that returns nil
    if not code_function then
        code_function, err = loadstring(code)
    end

    return code_function, err
end

function InstanceMethods:eval(code)
    local result
    local func, err = compile(code)

    if func and 'function' == type(func) then
        setfenv(func, self:get_fenv())
        result = make_result(pcall(func))

        if result.ok then
            self.env._ = result.val -- update last eval result
        end
    else
        result = make_result(false, err)
    end

    return result
end

--- Local Vars:
function InstanceMethods:find_local_var(name, match)
    local func = self.info.func
    if 'function' ~= type(func) then
        return
    end

    local function_index = get_function_index(func)

    -- Example: repl running from within coroutine (#26).
    if not function_index then
        return
    end

    local index = function_index - 1
    local i = 1
    local all_names = {}

    while true do
        local var_name, var_value = debug.getlocal(index, i)
        if not var_name then
            break
        end

        if match and safe_match(var_name, name) then
            table.insert(all_names, var_name)
        elseif name == var_name then
            -- "index - 1" is because stack will become deeper for a caller
            return true, var_name, var_value, index - 1, i
        end

        i = i + 1
    end

    if match then
        return all_names
    end
end

function InstanceMethods:set_local_var(name, value)
    local ok, _, _, index, var_index = self:find_local_var(name)

    if ok then
        debug.setlocal(index, var_index, value)
        return true
    end
end

--- Upvalues:
function InstanceMethods:find_upvalue(name, match)
    local func = self.info.func
    if 'function' ~= type(func) then
        return
    end

    local i = 1
    local all_names = {}

    while true do
        local var_name, var_value = debug.getupvalue(func, i)
        if not var_name then
            break
        end

        if match and safe_match(var_name, name) then
            table.insert(all_names, var_name)
        elseif name == var_name then
            return true, var_name, var_value, i
        end

        i = i + 1
    end

    if match then
        return all_names
    end
end

function InstanceMethods:set_upvalue(name, new_value)
    local func = self.info.func
    local ok, _, _, var_index = self:find_upvalue(name)

    if ok then
        debug.setupvalue(func, var_index, new_value)
        return true
    end
end

function InstanceMethods:get_fenv()
    return setmetatable({}, {
        __index = function(_, key)
            local found_local, _, local_value = self:find_local_var(key)
            if found_local then
                return local_value
            end

            local found_upvalue, _, upvalue_value = self:find_upvalue(key)
            if found_upvalue then
                return upvalue_value
            end

            return self.env[key]
        end,
        __newindex = function(_, key, value)
            local set_local = self:set_local_var(key, value)
            if set_local then
                return value
            end

            local set_upvalue = self:set_upvalue(key, value)
            if set_upvalue then
                return value
            end

            self.env[key] = value

            return value
        end
    })
end

function _M.new(caller_info)
    return setmetatable({
        info = caller_info,
        env = getfenv(caller_info.func)
    }, { __index = InstanceMethods })
end

return _M
