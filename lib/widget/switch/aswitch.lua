local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local switch    = {}

function switch:init()
    local ret   = {}

    ret.switch  = wibox.widget({
                                   checked = false,
                                   bg      = color.border,
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
                                   bg     = color.active_inner,
                                   shape  = gears.shape.rounded_bar,
                                   widget = wibox.container.background,
                               })

    ret.bg      = wibox.widget({
                                   ret.outline,
                                   shape_border_color = color.border_hover,
                                   shape              = gears.shape.rounded_bar,
                                   widget             = wibox.container.background,
                               })

    ret.textbox = widget:textbox("Switch")

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

    function ret:set_text(text)
        self.textbox = text or ""
    end

    function ret:set_checked(checked)
        ret.checked = checked

        if checked then
            ret.margin.left = 22

            ret.switch.bg   = color.active_inner
            ret.outline.bg  = color.border_hover
        else
            ret.margin.left = 0

            ret.switch.bg   = color.border
            ret.outline.bg  = color.active_inner
        end
    end

    wmapi:connect_signal(
            ret.widget,
            event.signals.button.release,
            event.mouse.button_click_left,
            function()
                ret:set_checked(not ret.checked)
            end
    )

    ret.widget:connect_signal(
            signals.mouse.enter,
            function()
                ret.bg.shape_border_width = beautiful.shape_border_width_enter
            end
    )

    ret.widget:connect_signal(
            signals.mouse.leave,
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