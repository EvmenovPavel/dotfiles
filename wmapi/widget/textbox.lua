local beautiful = require("beautiful")
local wibox     = require("wibox")

function init(argc)
    local textbox  = {}

    textbox.widget = wibox.widget({
                                      type   = "textbox",

                                      font   = beautiful.font,

                                      valign = "center",
                                      align  = "left",

                                      widget = wibox.widget.textbox,
                                  })

    textbox.widget:connect_signal(
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

    textbox.widget:connect_signal(
            capi.event.signals.mouse.leave,
            function(self)
                self.bg = beautiful.mouse_leave
                if self.old_wibox then
                    self.old_wibox.cursor = self.old_cursor
                    self.old_wibox        = nil
                end
            end
    )

    textbox.widget:connect_signal(
            capi.event.signals.button.press,
            function(self)
                self.bg = beautiful.button_press
            end
    )

    textbox.widget:connect_signal(
            capi.event.signals.button.release,
            function(self)
                self.bg = beautiful.button_release
            end
    )

    function textbox:set_text(text)
        self.widget.text = text or ""
    end

    function textbox:get()
        return self.widget
    end

    return textbox
end

return setmetatable({}, { __call = function(_, ...)
    return init(...)
end })
