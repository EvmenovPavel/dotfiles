local awful     = require("lib.awful")
local beautiful = require("lib.beautiful")
local wibox     = require("lib.wibox")

local wmapi     = require("wmapi")
local markup    = wmapi.markup
local resources = require("resources")
local config    = require("config")
local calendar  = require("widgets.calendar-clock.calendar")
local signals   = require("device.signals")

return function()
    local icon   = wmapi:imagebox(resources.widgets.calendar)

    local widget = awful.widget.textclock(markup.font(config.font, markup.fg.color(beautiful.colors.widget.fg_widget, "%A %d %B  %H:%M:%S")), 1)

    local cc     = wibox.widget({
                                    icon,
                                    wmapi:pad(1),
                                    widget,
                                    widget = wibox.layout.fixed.horizontal,
                                })

    local cw     = calendar({
                                theme     = "dark",
                                placement = "top_right"
                            })

    cc:connect_signal(signals.mouse.enter,
                      function()
                          cw.toggle()
                      end)
    cc:connect_signal(signals.mouse.leave,
                      function()
                          cw.toggle()
                      end)
    cc:connect_signal(signals.mouse.press,
                      function()
                          cw.buttons(0)
                      end)

    cc:buttons(awful.util.table.join(
            awful.button({}, 4,
                         function()
                             cw.buttons(4)
                         end),
            awful.button({}, 5,
                         function()
                             cw.buttons(5)
                         end)
    ))

    return cc
end