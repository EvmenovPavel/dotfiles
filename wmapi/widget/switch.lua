-- это
-- https://codepen.io/aaroniker/pen/ZEpEvdz
-- https://codepen.io/aaroniker/pen/ZEYoxEY


local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local switch    = {}

function switch:create()
    local ret            = {}

    local active         = "#275EFE"
    local active_inner   = "#ffffff"
    local focus          = "2px rgba(39, 94, 254, .3)"
    local border         = "#BBC1E1"
    local border_hover   = "#275EFE"
    local background     = "#fff"
    local disabled       = "#F6F8FF"
    local disabled_inner = "#E1E6F9"

    ret.switch           = wibox.widget({
                                            type         = "switch",

                                            checked      = false,

                                            color        = border,
                                            bg           = active_inner,

                                            border_width = 3,

                                            shape        = gears.shape.circle,
                                            widget       = wibox.widget.checkbox,
                                        })
    
    ret.margin = wibox.widget({
                                  {
                                      ret.switch,
                                      margins = 1,
                                      widget  = wibox.container.margin,
                                  },
                                  forced_width = 50,
                                  left         = 0,
                                  widget       = wibox.container.margin,
                              })

    ret.wid    = wibox.widget({
                                  ret.margin,
                                  bg     = border,
                                  shape  = gears.shape.rounded_bar,
                                  widget = wibox.container.background,
                              })

    ret.widget = wibox.widget({
                                  {
                                      ret.wid,
                                      margins = 1,
                                      widget  = wibox.container.margin,
                                  },

                                  shape_border_color = border_hover,
                                  bg                 = border,
                                  shape              = gears.shape.rounded_bar,
                                  widget             = wibox.container.background,
                              })

    function ret:set_checked(check)
        ret.checked = check

        if ret.checked then
            ret.margin.left  = 23

            ret.switch.color = border_hover
            ret.wid.bg       = border_hover
        else
            ret.margin.left  = 0

            ret.switch.color = border
            ret.wid.bg       = border
        end
    end

    ret.widget:connect_signal(
            capi.event.signals.button.release,
            function()
                ret:set_checked(not ret.checked)
            end
    )

    ret.widget:connect_signal(
            capi.event.signals.mouse.enter,
            function(self)
                self.shape_border_width = 1

                --local w                       = mouse.current_wibox
                --ret.old_cursor, ret.old_wibox = w.cursor, w
                --w.cursor                      = "hand1"
            end
    )

    ret.widget:connect_signal(
            capi.event.signals.mouse.leave,
            function(self)
                if not ret.checked then
                    self.shape_border_width = 0

                    --if ret.old_wibox then
                    --    ret.old_wibox.cursor = ret.old_cursor
                    --    ret.old_wibox        = nil
                    --end
                end
            end
    )

    function ret:get()
        return self.widget
    end

    return ret
end

return switch