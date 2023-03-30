local wibox  = require("wibox")
local gears  = require("gears")

local button = { mt = {} }

function button:init()
    local ret       = wmapi.widget:base("button")

    local __private = {}

    __private.func  = function()
        log:debug("button:create")
    end

    local w_textbox = wmapi.widget:textbox()
    w_textbox:text("button")
    function ret:textbox()
        return w_textbox
    end

    local w_imagebox = wmapi.widget:imagebox()
    function ret:imagebox()
        return w_imagebox
    end

    local w_mImagebox      = wibox.widget({
        w_imagebox:get(),
        margins = 5,
        widget  = wibox.container.margin,
    })

    local w_mTextbox       = wibox.widget({
        w_textbox:get(),
        right  = 5,
        widget = wibox.container.margin,
    })

    local w_text_image_box = wibox.widget({
        w_mImagebox,
        w_mTextbox,
        layout = wibox.layout.fixed.horizontal,
    })

    local w_bg             = wibox.widget({
        w_text_image_box,

        shape              = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 5)
        end,

        bg                 = ret:color():border(),
        shape_border_color = ret:color():border_hover(),
        widget             = wibox.container.background,
    })

    local widget           = wibox.widget({
        w_bg,
        layout = wibox.layout.fixed.horizontal,
    })
    ret:set_widget(widget, function()
        if wmapi:is_empty(w_imagebox:image()) then
            w_mImagebox.left = 0
        else
            w_mImagebox.margins = 5
        end
    end)

    ret:button():release(function(_, _, _, button)
        if button == event.mouse.button_click_left then
            __private.func()
            w_bg.bg = ret:color():border_hover()

            wmapi:weak_watch(function()
                w_bg.bg = ret:color():border()
            end, 0.1)
        end
    end)

    ret:mouse():enter(function(self)
        w_bg.shape_border_width = 1

        local w                 = _G.mouse.current_wibox
        if w then
            self.old_cursor, self.old_wibox = w.cursor, w
            w.cursor                        = "hand1"
        end
    end)

    ret:mouse():leave(function(self)
        w_bg.shape_border_width = 0
        w_bg.bg                 = ret:color():border()

        if self.old_wibox then
            self.old_wibox.cursor = self.old_cursor
            self.old_wibox        = nil
        end
    end)

    function ret:clicked(func)
        if type(func) == LuaTypes.func then
            __private.func = func
        end
    end

    function ret:get()
        ret:update_widget()
        return widget
    end

    return ret
end

return setmetatable(button, { __call = function()
    return button
end })
