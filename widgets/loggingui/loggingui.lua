local awful         = require("awful")
local wibox         = require("wibox")
local gears         = require("gears")
local resources     = require("resources")

local mouse         = capi.event.signals.mouse
local button        = capi.event.signals.button

local loggingui     = {}

local placement     = {
    top       = "top",
    top_right = "top_right",
    top_left  = "top_left"
}

local w_volume_icon = wibox.widget {
    image  = resources.widgets.volume.on,
    widget = wibox.widget.imagebox
}

function loggingui:toggle(popupWidget, calendarWidget)
    if popupWidget.visible then
        popupWidget:set_widget(nil)
        popupWidget:set_widget(calendarWidget)
        popupWidget.visible = not popupWidget.visible
    else
        if placement == "top" then
            awful.placement.top(popupWidget, { margins = { top = 30 }, parent = awful.screen.focused() })
        elseif placement == "top_right" then
            awful.placement.top_right(popupWidget, { margins = { top = 30, right = 10 }, parent = awful.screen.focused() })
        elseif placement == "bottom_right" then
            awful.placement.bottom_right(popupWidget, { margins = { bottom = 30, right = 10 }, parent = awful.screen.focused() })
        else
            awful.placement.top(popupWidget, { margins = { top = 30 }, parent = awful.screen.focused() })
        end

        popupWidget.visible = true
    end
end

awesome.connect_signal("loggingui_console",
                       function(stdout)
                           log:debug(stdout)
                       end
)

local function emit_signal(stdout)
    awesome.emit_signal("loggingui_console", stdout)
end

function loggingui:init()
    local placement       = placement.top_right

    local calendarWidget  = wibox.widget {
        date          = os.date("*t"),
        long_weekdays = true,
        widget        = wibox.widget.textbox
    }

    calendarWidget.markup = "ASDASDASDASD%"

    local popupWidget     = awful.popup {
        ontop        = true,
        visible      = false,
        shape        = gears.shape.rounded_rect,
        offset       = { y = 5 },
        border_width = 1,
        widget       = calendarWidget
    }

    w_volume_icon:connect_signal(button.release,
                                 function()
                                     self:toggle(popupWidget, calendarWidget)
                                 end)

    w_volume_icon:buttons(
            awful.util.table.join(
                    capi.wmapi:button({
                                          event = mouse.button_click_scroll_down,
                                          func  = function()
                                              popupWidget:set_widget(calendarWidget)
                                          end
                                      }),
                    capi.wmapi:button({ event = mouse.button_click_scroll,
                                        func  = function()
                                            popupWidget:set_widget(calendarWidget)
                                        end
                                      })
            )
    )

    log:set_signal(emit_signal)

    return w_volume_icon
end

return setmetatable(loggingui, { __call = function(_, ...)
    return loggingui:init(...)
end })
