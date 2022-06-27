local wibox  = require("wibox")
local gears  = require("gears")

local switch = {}

function switch:init()
    local public           = wmapi:widget():base("switch")

    local private          = {}

    private.checked        = false
    private.event          = event.mouse.button_click_left
    private.function_true  = function()
        log:debug("switch:create - true")
    end
    private.function_false = function()
        log:debug("switch:create - false")
    end

    local switch           = wibox.widget({
                                              checked = false,
                                              bg      = color.border,
                                              shape   = gears.shape.circle,
                                              widget  = wibox.widget.checkbox
                                          })

    local margin           = wibox.widget({
                                              {
                                                  switch,
                                                  margins = 3,
                                                  widget  = wibox.container.margin,
                                              },
                                              forced_width = 50,
                                              left         = 0,
                                              widget       = wibox.container.margin,
                                          })

    local outline          = wibox.widget({
                                              margin,
                                              bg     = color.active_inner,
                                              shape  = gears.shape.rounded_bar,
                                              widget = wibox.container.background,
                                          })

    local bg               = wibox.widget({
                                              outline,
                                              shape_border_color = color.border_hover,
                                              shape              = gears.shape.rounded_bar,
                                              widget             = wibox.container.background,
                                          })

    local textbox          = wmapi:widget():textbox()

    local widget           = wibox.widget({
                                              {
                                                  bg,
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

    function public:set_text(text)
        if type(text) == LuaTypes.string then
            textbox:text(text)
        end

        return "Error: not string"
    end

    function public:set_event(event)
        if type(event) == LuaTypes.number then
            private.event = event
        end

        return "Error: event not number"
    end

    function public:set_function(func, checked)
        local f = {}

        function f:checked(func)
            if type(func) == LuaTypes.fun then
                private.function_true = func
            else
                private.function_true = function()
                    func()
                end
            end
        end

        function f:unchecked(func)
            if type(func) == LuaTypes.fun then
                private.function_false = func
            else
                private.function_false = function()
                    func()
                end
            end
        end

        local checked = checked or true
        if checked then
            f:checked(func)
        else
            f:unchecked(func)
        end
    end

    function public:trigger(checked)
        if type(checked) == LuaTypes.boolean then
            private.checked = checked

            if private.checked then
                margin.left = 22

                switch.bg   = color.active_inner
                outline.bg  = color.border_hover

                private.function_true()
            else
                margin.left = 0

                switch.bg   = color.border
                outline.bg  = color.active_inner

                private.function_false()
            end
        end
    end

    widget:connect_signal(
            event.signals.button.release,
            function(_, _, _, b)
                if b == private.event then
                    public:trigger(not private.checked)
                end
            end
    )

    widget:connect_signal(
            event.signals.mouse.enter,
            function()
                bg.shape_border_width = 1
            end
    )

    widget:connect_signal(
            event.signals.mouse.leave,
            function()
                if not private.checked then
                    bg.shape_border_width = 0
                end
            end
    )

    function public:get()
        return widget
    end

    return public
end

return switch