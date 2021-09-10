local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local checkbox  = {}

-- https://codepen.io/flavio_amaral/pen/xxqQLoa
-- https://codepen.io/KenanYusuf/pen/PZKEKd

-- это
-- https://codepen.io/aaroniker/pen/ZEpEvdz
-- https://codepen.io/aaroniker/pen/ZEYoxEY

function checkbox:create()
    local ret            = {}

    local active         = "#275EFE"
    local active_inner   = "#ffffff"
    local focus          = "2px rgba(39, 94, 254, .3)"
    local border         = "#BBC1E1"
    local border_hover   = "#275EFE"
    local background     = "#fff"
    local disabled       = "#F6F8FF"
    local disabled_inner = "#E1E6F9"

    ret.checkbox         = wibox.widget({
                                            type         = "checkbox",

                                            checked      = false,

                                            bg           = border,
                                            border_color = border_hover,
                                            border_width = 0,

                                            shape        = function(cr, w, h)
                                                gears.shape.rounded_rect(cr, w, h, 5)
                                            end,

                                            widget       = wibox.widget.checkbox,
                                        })

    ret.widget           = wibox.widget({
                                            --{
                                            ret.checkbox,
                                            --margins = 1,
                                            --widget  = wibox.container.margin,
                                            --},


                                            shape              = function(cr, w, h)
                                                gears.shape.rounded_rect(cr, w, h, 5)
                                            end,

                                            shape_border_color = border_hover,
                                            bg                 = border,
                                            widget             = wibox.container.background,
                                        })

    ret.widget:connect_signal(
            capi.event.signals.mouse.enter,
            function(self)
                self.shape_border_width = 1
            end
    )

    ret.widget:connect_signal(
            capi.event.signals.mouse.leave,
            function(self)
                if not ret.checked then
                    self.shape_border_width = 0
                end
            end
    )

    ret.checkbox:connect_signal(
            capi.event.signals.button.release,
            function(self)
                --self.bg            = beautiful.button_release
                ret:checked(not self.checked)
            end
    )

    function ret:get()
        return self.widget
    end

    function ret:checked(check)
        self.checkbox.checked = check
    end

    return ret
end

return checkbox
