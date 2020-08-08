local type    = type

local types   = require("lib.wmapi.types")

local timer   = type(timer) == "table" and timer or require("lib.gears.timer")

local vicious = {}
local timers  = {}

local function update(widget, reg)
    local update_time = os.time()

    local function format_data(data)
        local ret
        if type(data) == "table" then
            if type(data) == "string" then
                ret = data
            elseif type(data) == "function" then
                if type(data) == "string" then
                    ret = data()
                end
            end
        elseif type(data) == "function" then
            local fun = data()
            if type(fun) == "string" then
                ret = fun
            end
        end

        return ret
    end

    local function update_value(data)
        local fmtd_data = format_data(data)

        if reg.type == types.textbox then
            widget:set_markup(fmtd_data)
        elseif reg.type == types.imagebox then
            widget:set_image(fmtd_data)
        end
    end

    local function update_cache(data, t, cache)
        if t and cache then
            cache.time, cache.data = t, data
        end
    end

    if reg then
        if not reg.lock then
            reg.lock = true
            update_cache(reg.callback, update_time, reg)
            update_value(reg.callback)
            reg.lock = false
        end
    end
end

local function start(reg)
    if not reg.running then
        if reg.timeout > 0 then
            local tm = timers[reg.timeout] and timers[reg.timeout].timer
            tm       = tm or timer({ timeout = reg.timeout })
            if tm.connect_signal then
                tm:connect_signal("timeout", reg.update)
            else
                tm:add_signal("timeout", reg.update)
            end
            if not timers[reg.timeout] then
                timers[reg.timeout] = { timer = tm, refs = 1 }
            else
                timers[reg.timeout].refs = timers[reg.timeout].refs + 1
            end
            if not tm.started then
                tm:start()
            end
            reg.update()
        end
        reg.running = true
    end
end

function vicious:create(widget, callback, timeout)
    local reg = {
        callback = callback,
        timeout  = timeout or 1,
        widget   = widget,
        type     = widget.type
    }
    reg.timer = timeout

    function reg.update()
        update(widget, reg)
    end

    start(reg)

    return reg
end

return vicious