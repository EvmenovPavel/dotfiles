local wibox = require("wibox")
local gears = require("gears")

local checkbox = {}

function checkbox:init()
    local ret = wmapi.widget:base("checkbox")

    local __private = {}

    __private.checked = false
    __private.func_checked = function()
        log:debug("checkbox:checked")
    end
    __private.func_unchecked = function()
        log:debug("checkbox:unchecked")
    end

    local w_textbox = wmapi.widget:textbox("checkbox")
    function ret:textbox()
        return w_textbox
    end

    local w_imagebox = wmapi.widget:imagebox()
    w_imagebox:image(resources.checkbox.checkbox)
    function ret:imagebox()
        return w_imagebox
    end

    local w_checkbox = wibox.widget({
        w_imagebox:get(),
        bg = color.border,
        widget = wibox.container.background,
    })

    local w_bg = wibox.widget({
        {
            w_checkbox,
            margins = 2,
            widget = wibox.container.margin,
        },

        shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 5)
        end,

        bg = color.border,
        shape_border_color = color.border_hover,
        widget = wibox.container.background,
    })

    local widget = wibox.widget({
        {
            w_bg,
            widget = wibox.container.background,
        },
        {
            right = 5,
            widget = wibox.container.margin,
        },
        {
            w_textbox:get(),
            widget = wibox.container.background,
        },
        layout = wibox.layout.fixed.horizontal,
    })
    ret:set_widget(widget, function(check)
        __private.checked = check

        if __private.checked then
            w_bg.bg = color.border_hover
            w_checkbox.bg = color.border_hover
        else
            w_bg.bg = color.border
            w_checkbox.bg = color.border
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

    function ret:is_checked()
        return __private.checked
    end

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

    function ret:get()
        return widget
    end

    return ret
end

return setmetatable(checkbox, { __call = function()
    return checkbox
end })

