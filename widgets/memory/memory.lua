local wibox       = require("wibox")
local beautiful   = require("beautiful")

local memory      = {}

local memory_rows = {
    spacing = 4,
    layout  = wibox.layout.fixed.vertical,
}

function row(name, str)
    local row = wibox.widget {
        capi.wmapi:textbox({ markup = name }),
        capi.wmapi:textbox({ markup = str }),
        layout = wibox.layout.ratio.horizontal
    }

    row:ajust_ratio(2, 0.15, 0.15, 0.7)

    return row
end

local wGraphBox = capi.wmapi:graph()
local wTextBox  = capi.wmapi:textbox({ forced_width = 60 })
local popup     = capi.wmapi:popup()

function memory:init()
    local bash = [[bash -c "cat /proc/meminfo"]]
    capi.wmapi:watch(bash, 3,
                     function(stdout)
                         local _mem = { buf = {}, swp = {} }

                         -- Get MEM info
                         for line in stdout:gmatch("[^\r\n]+") do
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
                         _mem.free       = _mem.buf.a
                         _mem.inuse      = _mem.total - _mem.free
                         _mem.bcuse      = _mem.total - _mem.buf.f
                         _mem.usep       = math.floor(_mem.inuse / _mem.total * 100)
                         -- Calculate swap percentage
                         _mem.swp.inuse  = _mem.swp.t - _mem.swp.f
                         _mem.swp.usep   = math.floor(_mem.swp.inuse / _mem.swp.t * 100)

                         wTextBox.markup = "Mem [" .. tostring(_mem.usep) .. "]"
                         wGraphBox:add_value(_mem.usep)

                         memory_rows[1] = row("free", _mem.free)
                         memory_rows[2] = row("inuse", _mem.inuse)
                         memory_rows[3] = row("bcuse", _mem.bcuse)
                         memory_rows[4] = row("usep", _mem.usep)
                         memory_rows[5] = row("swp.inuse", _mem.swp.inuse)
                         memory_rows[6] = row("swp.usep", _mem.swp.usep)

                         popup:setup {
                             {
                                 memory_rows,
                                 {
                                     orientation   = "horizontal",
                                     forced_height = 15,
                                     color         = beautiful.bg_focus,
                                     widget        = wibox.widget.separator
                                 },
                                 layout = wibox.layout.fixed.vertical,
                             },
                             margins = 8,
                             widget  = wibox.container.margin
                         }
                     end)

    local wText  = wibox.container.margin(wibox.container.mirror(wTextBox, { horizontal = false }), 2, 2, 2, 2)
    local wGraph = wibox.container.margin(wibox.container.mirror(wGraphBox, { horizontal = true }), 2, 2, 2, 2)

    local widget = wibox.widget({
                                    wText,
                                    --wGraph,
                                    layout = wibox.layout.align.horizontal
                                })

    local func   = function()
        if popup.visible then
            popup.visible = not popup.visible
        else
            popup:move_next_to(capi.mouse.current_widget_geometry)
        end
    end

    capi.wmapi:buttons({ widget = widget, func = func })

    return widget
end

return setmetatable(memory, {
    __call = memory.init
})

