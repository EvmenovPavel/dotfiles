local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local button    = {}

function button:create(argc)
    local ret    = {}

    local argc   = argc or {}
    local text   = argc.text or "PushButton"
    local src    = argc.src or ""

    ret.textbox  = capi.widget:textbox(text)
    ret.imagebox = capi.widget:imagebox({ src = src })

    ret.widget   = wibox.widget({
                                    {
                                        {
                                            ret.imagebox:get(),
                                            ret.textbox:get(),
                                            layout = wibox.layout.fixed.horizontal,
                                        },
                                        margins = 6,
                                        widget  = wibox.container.margin,
                                    },
                                    --shape_border_color = beautiful.border_hover_color,
                                    --shape              = gears.shape.rounded_bar,

                                    widget = wibox.container.background(),
                                })

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

    function ret:get()
        self.widget.type = "button"
        return self.widget
    end

    function ret:set_text(text)
        ret.textbox:set_text(text)
    end

    function ret:set_image(src)
        ret.imagebox:set_image(src)
    end

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

    ret:set_style()
    ret:set_button(argc)

    return ret
end

return button