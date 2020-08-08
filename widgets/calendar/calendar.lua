local awful          = require("lib.awful")
local gears          = require("lib.gears")
local wibox          = require("lib.wibox")
local beautiful      = require("lib.beautiful")

local config         = require("config")
local wmapi          = require("lib.wmapi")
local markup         = wmapi.markup

local clock_widget   = wibox.widget.textclock(markup.font(beautiful.title_font, config.datetime), 1)

local cal_shape      = function(cr, width, height)
    gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, 12)
end

-- Calendar Widget
local month_calendar = awful.widget.calendar_popup.month({
                                                             start_sunday  = true,
                                                             spacing       = 10,
                                                             font          = beautiful.title_font,
                                                             long_weekdays = true,
                                                             margin        = 0, -- 10
                                                             style_month   = { border_width = 0, padding = 12, shape = cal_shape, padding = 25 },
                                                             style_header  = { border_width = 0, bg_color = "#00000000" },
                                                             style_weekday = { border_width = 0, bg_color = "#00000000" },
                                                             style_normal  = { border_width = 0, bg_color = "#00000000" },
                                                             style_focus   = { border_width = 0, bg_color = "#8AB4F8" },
                                                         })

-- Attach calentar to clock_widget
month_calendar:attach(clock_widget, "tc", { on_pressed = true, on_hover = false })

return clock_widget
