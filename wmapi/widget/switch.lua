-- это
-- https://codepen.io/aaroniker/pen/ZEpEvdz
-- https://codepen.io/aaroniker/pen/ZEYoxEY


local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local switch    = {}

function switch:create()
    local ret   = {}

    ret.switch  = wibox.widget({
                                   checked = false,
                                   bg      = capi.color.border,
                                   shape   = gears.shape.circle,
                                   widget  = wibox.widget.checkbox
                               })

    ret.margin  = wibox.widget({
                                   {
                                       ret.switch,
                                       margins = 3,
                                       widget  = wibox.container.margin,
                                   },
                                   forced_width = 50,
                                   left         = 0,
                                   widget       = wibox.container.margin,
                               })

    ret.outline = wibox.widget({
                                   ret.margin,
                                   bg     = capi.color.active_inner,
                                   shape  = gears.shape.rounded_bar,
                                   widget = wibox.container.background,
                               })

    ret.bg      = wibox.widget({
                                   ret.outline,
                                   shape_border_color = capi.color.border_hover,
                                   shape              = gears.shape.rounded_bar,
                                   widget             = wibox.container.background,
                               })

    ret.textbox = capi.widget:textbox("Switch")

    ret.widget  = wibox.widget({
                                   {
                                       ret.bg,
                                       widget = wibox.container.background,
                                   },
                                   {
                                       right  = 5,
                                       widget = wibox.container.margin,
                                   },
                                   {
                                       ret.textbox:get(),
                                       widget = wibox.container.background,
                                   },
                                   layout = wibox.layout.fixed.horizontal,
                               })

    function ret:set_checked(check)
        ret.checked = check

        if ret.checked then
            ret.margin.left = 22

            ret.switch.bg   = capi.color.active_inner
            ret.outline.bg  = capi.color.border_hover
        else
            ret.margin.left = 0

            ret.switch.bg   = capi.color.border
            ret.outline.bg  = capi.color.active_inner
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
            function()
                ret.bg.shape_border_width = beautiful.shape_border_width_enter
            end
    )

    ret.widget:connect_signal(
            capi.event.signals.mouse.leave,
            function()
                if not ret.checked then
                    ret.bg.shape_border_width = beautiful.shape_border_width_leave
                end
            end
    )

    function ret:get()
        self.widget.type = "switch"
        return self.widget
    end

    return ret
end

return switch