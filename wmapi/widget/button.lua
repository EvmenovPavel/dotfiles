local awful  = require("awful")
local wibox  = require("wibox")
local gears  = require("gears")

local button = {}

function button:init()
    self.widget = wibox.widget({
                                   type   = "button",
                                   widget = wibox.container.background(),
                               })

    self.widget:connect_signal(
            capi.event.signals.mouse.enter,
            function(self)
                self.bg = "#ffffff11"
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
                self.bg = "#ffffff00"
                if self.old_wibox then
                    self.old_wibox.cursor = self.old_cursor
                    self.old_wibox        = nil
                end
            end
    )

    self.widget:connect_signal(
            capi.event.signals.button.press,
            function(self)
                self.bg = "#ffffff22"
            end
    )

    self.widget:connect_signal(
            capi.event.signals.button.release,
            function(self)
                self.bg = "#ffffff11"
            end
    )

    return self
end

function button:set_widget(...)
    if not self.res then
        self.res = wibox.widget({
                                    layout = wibox.layout.fixed.horizontal()
                                })
    end

    for i = 1, select("#", ...) do
        local item = select(i, ...)

        capi.log:message(item.type)

        if item then
            local widget = item.widget
            if widget then
                --self.res:add(widget)
            else
                --self.res:add(item)
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
                            nil,
                            func
                    )
            )
    )
end

function button:set_text(text)
    local textbox = capi.widget:textbox()
    textbox:set_text(text)
    self:set_widget(textbox)
end

function button:set_icon(src)
    local imagebox = capi.widget:imagebox({ src = src })
    self:set_widget(imagebox)
end

return setmetatable(button, { __call = function()
    return button:init()
end })
