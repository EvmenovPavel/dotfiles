local beautiful = require("lib.beautiful")
local wibox     = require("lib.wibox")

local wmapi     = require("wmapi")
local timer     = wmapi.timer
local markup    = wmapi.markup
local resources = require("resources")
local config    = require("config")

local function meminfo()
    local _mem = { buf = {}, swp = {} }

    -- Get MEM info
    for line in io.lines("/proc/meminfo") do
        for k, v in string.gmatch(line, "([%a]+):[%s]+([%d]+).+") do
            if k == "MemTotal" then
                _mem.total = math.floor(v / 1024)
            elseif k == "MemFree" then
                _mem.buf.f = math.floor(v / 1024)
            elseif k == "MemAvailable" then
                _mem.buf.a = math.floor(v / 1024)
            elseif k == "Buffers" then
                _mem.buf.b = math.floor(v / 1024)
            elseif k == "Cached" then
                _mem.buf.c = math.floor(v / 1024)
            elseif k == "SwapTotal" then
                _mem.swp.t = math.floor(v / 1024)
            elseif k == "SwapFree" then
                _mem.swp.f = math.floor(v / 1024)
            end
        end
    end

    -- Calculate memory percentage
    _mem.free      = _mem.buf.a
    _mem.inuse     = _mem.total - _mem.free
    _mem.bcuse     = _mem.total - _mem.buf.f
    _mem.usep      = math.floor(_mem.inuse / _mem.total * 100)
    -- Calculate swap percentage
    _mem.swp.inuse = _mem.swp.t - _mem.swp.f
    _mem.swp.usep  = math.floor(_mem.swp.inuse / _mem.swp.t * 100)

    return _mem
end

return function()
    local widget = wmapi:textbox()
    local icon   = wmapi:imagebox(resources.widgets.memory)

    timer:create(widget,
                 function()
                     local mem = meminfo()
                     return markup.font(config.font, markup.fg.color(beautiful.colors.widget.fg_widget, mem.usep .. "%"))
                 end, 1)

    local memory = wibox.widget({
                                    icon,
                                    wmapi:pad(2),
                                    widget,
                                    widget = wibox.layout.fixed.horizontal,
                                })

    return memory
end
