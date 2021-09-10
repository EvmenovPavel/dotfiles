local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local button    = {}

function button:create(argc)
    local ret  = {}

    ret.res    = wibox.widget({
                                  layout = wibox.layout.fixed.horizontal
                              })

    ret.widget = wibox.widget({
                                  type   = "button",
                                  widget = wibox.container.background,
                              })

    function ret:set_button(argc)
        local argc  = argc or {}

        local key   = argc.key or {}
        local event = argc.event or capi.event.mouse.button_click_left
        local func  = argc.func or function()
            capi.log:message("button:init")
        end

        self.widget:buttons(
                gears.table.join(
                        awful.button(key,
                                     event,
                                     nil,
                                     func)
                )
        )
    end

    ret:set_button(argc)

    function ret:set_style(bg_enter, bg_leave, bg_press, bg_release)
        local bg_enter   = bg_enter or beautiful.mouse_enter
        local bg_leave   = bg_leave or beautiful.mouse_leave
        local bg_press   = bg_press or beautiful.button_press
        local bg_release = bg_release or beautiful.button_release

        self.widget:connect_signal(
                capi.event.signals.mouse.enter,
                function(self)
                    self.bg = bg_enter
                    local w = _G.mouse.current_wibox
                    if w then
                        self.old_cursor, self.old_wibox = w.cursor, w
                        w.cursor                        = "hand1"
                    end
                end
        )

        self.widget:connect_signal(
                capi.event.signals.mouse.leave,
                function(self)
                    self.bg = bg_leave
                    if self.old_wibox then
                        self.old_wibox.cursor = self.old_cursor
                        self.old_wibox        = nil
                    end
                end
        )

        self.widget:connect_signal(
                capi.event.signals.button.press,
                function(self)
                    self.bg = bg_press
                end
        )

        self.widget:connect_signal(
                capi.event.signals.button.release,
                function(self)
                    self.bg = bg_release
                end
        )
    end

    function ret:set_widget(...)
        for i = 1, select("#", ...) do
            local item = select(i, ...)

            if item then
                local widget = item.widget
                if widget then
                    self.res:add(widget)
                else
                    self.res:add(item)
                end
            end
        end

        self.widget:set_widget(self.res)
    end

    function ret:get()
        return self.widget
    end

    function ret:set_text(text)
        local textbox = capi.widget:textbox()
        textbox:set_text(text)
        self:set_widget(textbox)
    end

    function ret:set_image(src)
        local imagebox = capi.widget:imagebox({ src = src })
        self:set_widget(imagebox)
    end

    return ret
end

return button