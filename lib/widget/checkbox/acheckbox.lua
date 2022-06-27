local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local checkbox  = {}

function checkbox:init(text, src, key, event, func)
    local ret      = widget:base("checkbox")

    ret.res        = wibox.widget({ layout = wibox.layout.fixed.horizontal })

    local imagebox = widget:imagebox()
    imagebox:set_image(resources.checkbox.checkbox)

    local textbox = widget:textbox("checkbox")

    ret.checkbox  = wibox.widget({
                                     imagebox:get(),
                                     bg     = color.border,
                                     widget = wibox.container.background,
                                 })

    ret.bg        = wibox.widget({
                                     {
                                         ret.checkbox,
                                         margins = 2,
                                         widget  = wibox.container.margin,
                                     },

                                     shape              = function(cr, w, h)
                                         gears.shape.rounded_rect(cr, w, h, 5)
                                     end,

                                     shape_border_color = color.border_hover,
                                     bg                 = color.border,
                                     widget             = wibox.container.background,
                                 })

    ret.widget    = wibox.widget({
                                     {
                                         ret.bg,
                                         widget = wibox.container.background,
                                     },
                                     {
                                         right  = 5,
                                         widget = wibox.container.margin,
                                     },
                                     {
                                         textbox:get(),
                                         widget = wibox.container.background,
                                     },
                                     layout = wibox.layout.fixed.horizontal,
                                 })

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

    ret.widget:connect_signal(
            signals.button.release,
            function(_, _, _, button)
                if button == mouse.button_click_left then
                    ret:set_checked(not ret.checked)
                end
            end
    )

    function ret:set_checked(check)
        ret.checked = check

        if ret.checked then
            ret.bg.bg       = color.border_hover
            ret.checkbox.bg = color.border_hover
        else
            ret.bg.bg       = color.border
            ret.checkbox.bg = color.border
        end
    end

    function ret:get()
        self.widget.type = "checkbox"
        return self.widget
    end

    return ret
end

return checkbox
