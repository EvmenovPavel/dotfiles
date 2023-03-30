local beautiful = require("beautiful")
local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local watch     = require("awful.widget.watch")

local pacmd     = {}

local function init()
    local pacmd_widget = wibox.widget {
        checked  = false,
        color    = "#ffffff",
        paddings = 2,
        shape    = gears.shape.circle,
        widget   = wibox.widget.checkbox
    }

    local text_widget  = wibox.widget {
        font   = beautiful.font,

        widget = wibox.widget.textbox,
        markup = "AUX",

        align  = "left",
        valign = "center",
    }

    watch([[bash -c "pacmd list-modules | grep latency_msec=5"]], 1,
            function(widget, stdout)
                --log:debug(stdout)

                if wmapi:is_empty(stdout) then
                    --awful.spawn("pacmd load-module module-loopback latency_msec=5", false)
                    widget.checked = false
                else
                    widget.checked = true
                end

                --pacmd unload-module module-loopback

                --pacmd list-modules | grep latency_msec=5

                --pacmd load-module module-loopback latency_msec=5


                --widget:add_value()
            end,
            pacmd_widget
    )

    local margin_widget = wibox.container.margin(wibox.container.mirror(pacmd_widget, { horizontal = true }), 2, 2, 2, 2)

    local margin_text   = wibox.container.margin(wibox.container.mirror(text_widget, { horizontal = false }), 2, 2, 2, 2)

    local widget        = wibox.widget {
        margin_text,
        margin_widget,
        layout = wibox.layout.align.horizontal
    }

    return widget
end

return setmetatable(pacmd, { __call = function(_, ...)
    return init(...)
end })
