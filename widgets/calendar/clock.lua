local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")

local markup    = capi.wmapi.markup
local resources = require("resources")
local calendar  = require("widgets.calendar.calendar")
local signals   = require("event").signals

--return function()
local icon      = capi.wmapi:imagebox(resources.widgets.calendar)

local widget    = wibox.widget.textclock(markup.font(beautiful.font, beautiful.datetime), 1)

local cc        = wibox.widget({
                                   icon,
                                   capi.wmapi:pad(1),
                                   widget,
                                   widget = wibox.layout.fixed.horizontal,
                               })

local cw        = calendar({
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
--end