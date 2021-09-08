local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local function init()
    local button  = {}

    button.widget = wibox.widget({
                                     type   = "button",
                                     widget = wibox.container.background(),
                                 })

    button.widget:connect_signal(
            capi.event.signals.mouse.enter,
            function(self)
                self.bg = beautiful.mouse_enter
                local w = _G.mouse.current_wibox
                if w then
                    self.old_cursor, self.old_wibox = w.cursor, w
                    w.cursor                        = "hand1"
                end
            end
    )

    button.widget:connect_signal(
            capi.event.signals.mouse.leave,
            function(self)
                self.bg = beautiful.mouse_leave
                if self.old_wibox then
                    self.old_wibox.cursor = self.old_cursor
                    self.old_wibox        = nil
                end
            end
    )

    button.widget:connect_signal(
            capi.event.signals.button.press,
            function(self)
                self.bg = beautiful.button_press
            end
    )

    button.widget:connect_signal(
            capi.event.signals.button.release,
            function(self)
                self.bg = beautiful.button_release
            end
    )

    function button:set_widget(...)
        if not button.res then
            button.res = wibox.widget({
                                          layout = wibox.layout.fixed.horizontal()
                                      })
        end

        for i = 1, select("#", ...) do
            local item = select(i, ...)

            capi.log:message(item.type)

            if item then
                local widget = item.widget
                if widget then
                    --if LuaWidgetTypes[widget.type] then
                    self.res:add(widget)
                    --end
                else
                    self.res:add(item)
                end
            end
        end

        self.widget:set_widget(self.res)
    end

    function button:set_button(argc)
        local argc  = argc or {}

        local key   = argc.key or {}
        local event = argc.event or capi.event.mouse.button_click_left
        local func  = argc.func or function()
            capi.log:message("button:init")
        end

        self.widget:buttons(
                gears.table.join(
                        awful.button(
                                key,
                                event,
                                func
                        )
                )
        )
    end

    function button:get()
        return self.widget
    end

    function button:set_text(text)
        --local textbox = capi.widget:textbox()
        --textbox:set_text(text)
        --self:set_widget(textbox)
    end

    function button:set_icon(src)
        local imagebox = capi.widget:imagebox({ src = src })
        self:set_widget(imagebox)
    end

    return button
end

return setmetatable({ }, { __call = function()
    return init()
end })
