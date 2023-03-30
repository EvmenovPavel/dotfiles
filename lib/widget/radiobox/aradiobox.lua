local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local radiobox  = {}

function radiobox:create(text, func)
    local ret    = {}

    ret.radiobox = wibox.widget({
        checked = false,
        shape   = gears.shape.circle,
        widget  = wibox.widget.checkbox
    })

    ret.textbox  = widget:textbox(text)

    ret.outline  = wibox.widget({
        {
            ret.radiobox,
            margins = 5,
            widget  = wibox.container.margin,
        },
        shape  = gears.shape.rounded_bar,
        widget = wibox.container.background,
    })

    ret.bg       = wibox.widget({
        ret.outline,
        shape_border_color = color.border_hover,
        bg                 = color.active_inner,
        shape              = gears.shape.rounded_bar,
        widget             = wibox.container.background,
    })

    ret.widget   = wibox.widget({
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
            function()
                func()
            end
    )

    function ret:enable()
        ret.radiobox.bg = color.active_inner
        ret.widget.bg   = color.border_hover
        ret.outline.bg  = color.border_hover
    end

    function ret:disable()
        ret.widget.bg  = color.active_inner
        ret.outline.bg = color.active_inner
    end

    return ret
end

return radiobox