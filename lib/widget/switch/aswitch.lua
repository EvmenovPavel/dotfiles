local wibox  = require("wibox")
local gears  = require("gears")

local switch = {}

function switch:init()
    local ret                = wmapi.widget:base("switch")

    local __private          = {}

    __private.checked        = false
    __private.func_checked   = function()
        log:debug("switch:checked")
    end
    __private.func_unchecked = function()
        log:debug("switch:unchecked")
    end

    local w_switch           = wibox.widget({
        checked = false,
        bg      = color.border,
        shape   = gears.shape.circle,
        widget  = wibox.widget.checkbox
    })

    local w_margin           = wibox.widget({
        {
            w_switch,
            margins = 3,
            widget  = wibox.container.margin,
        },
        forced_width = 50,
        left         = 0,
        widget       = wibox.container.margin,
    })

    local w_outline          = wibox.widget({
        w_margin,
        bg     = color.active_inner,
        shape  = gears.shape.rounded_bar,
        widget = wibox.container.background,
    })

    local w_bg               = wibox.widget({
        {
            w_outline,
            margins = 0.25,
            widget  = wibox.container.margin,
        },
        bg                 = color.active,
        shape_border_color = color.border_hover,
        shape              = gears.shape.rounded_bar,
        widget             = wibox.container.background,
    })

    local w_textbox          = wmapi.widget:textbox()
    function ret:textbox()
        return w_textbox
    end

    local widget = wibox.widget({
        {
            w_bg,
            widget = wibox.container.background,
        },
        {
            right  = 5,
            widget = wibox.container.margin,
        },
        {
            w_textbox,
            widget = wibox.container.background,
        },
        layout = wibox.layout.fixed.horizontal,
    })
    ret:set_widget(widget, function(checked)
        if type(checked) == LuaTypes.boolean then
            __private.checked = checked

            if __private.checked then
                w_margin.left = 22

                w_switch.bg   = color.active_inner
                w_outline.bg  = color.border_hover
            else
                w_margin.left = 0

                switch.bg     = color.border
                w_outline.bg  = color.active_inner
            end
        end
    end)

    ret:button():release(function(_, _, _, button)
        if button == event.mouse.button_click_left then
            ret:update_widget(not __private.checked)

            if __private.checked then
                __private.func_checked()
            else
                __private.func_unchecked()
            end
        end
    end)

    ret:mouse():enter(function()
        w_bg.shape_border_width = 1
    end)

    ret:mouse():leave(function()
        if not __private.checked then
            w_bg.shape_border_width = 0
        end
    end)

    function ret:unchecked(func)
        if type(func) == LuaTypes.func then
            __private.func_unchecked = func
        end
    end

    function ret:checked(func)
        if type(func) == LuaTypes.func then
            __private.func_checked = func
        end
    end

    function ret:is_checked()
        return __private.checked
    end

    function ret:get()
        return widget
    end

    return ret
end

return setmetatable(switch, { __call = function()
    return switch
end })
