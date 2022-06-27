local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local button    = {}

local function connect_signal(widget, bg_enter, bg_leave, bg_press, bg_release)
    local bg_enter   = bg_enter or beautiful.mouse_enter or "#ffffff11"
    local bg_leave   = bg_leave or beautiful.mouse_leave or "#ffffff00"
    local bg_press   = bg_press or beautiful.button_press or "#ffffff22"
    local bg_release = bg_release or beautiful.button_release or "#ffffff11"

    widget:connect_signal(
            event.signals.mouse.enter,
            function(self)
                self.bg = bg_enter

                local w = _G.mouse.current_wibox
                if w then
                    self.old_cursor, self.old_wibox = w.cursor, w
                    w.cursor                        = "hand1"
                end
            end
    )

    widget:connect_signal(
            event.signals.mouse.leave,
            function(self)
                self.bg = bg_leave
                if self.old_wibox then
                    self.old_wibox.cursor = self.old_cursor
                    self.old_wibox        = nil
                end
            end
    )

    widget:connect_signal(
            event.signals.button.press,
            function(self)
                self.bg = bg_press
            end
    )

    widget:connect_signal(
            event.signals.button.release,
            function(self)
                self.bg = bg_release
            end
    )
end

local function button_join(widget)
    --widget:buttons(
    --        gears.table.join(
    --                awful.button(ret._private.key,
    --                             ret._private.event,
    --                             nil,
    --                             ret._private.func)
    --        )
    --)
end

function button:init()
    local public  = wmapi:widget():base("button")

    local private = {}

    private.text  = "Button"
    private.src   = ""
    private.key   = {}
    private.event = event.mouse.button_click_left
    private.func  = function()
        log:debug("button:create")
    end

    local textbox = wmapi:widget():textbox(text)
    local widget  = wibox.container.background()
    widget:set_widget(textbox:get())

    widget:connect_signal("mouse::enter",
                          function(_1, _2, _3, b)
                              log:debug("mouse::enter > _1", _1, "_2", _2, "_3", _3, "b", b)
                          end)

    widget:connect_signal("mouse::leave",
                          function(_1, _2, _3, b)
                              log:debug("mouse::leave > _1", _1, "_2", _2, "_3", _3, "b", b)
                          end)

    widget:connect_signal(event.signals.button.release,
                          function(_, _, _, b)
                              if b == private.event then
                                  private.func()
                              end
                          end
    )

    widget:connect_signal(
            event.signals.button.press,
            function(_, _, _, button)
                if button == private.event then

                end
            end
    )

    --widget:connect_signal("focus", update)
    --widget:connect_signal("unfocus", update)

    function public:set_text(text)
        private.text = text
        textbox:text(private.text)
    end

    function public:set_function(func)
        if type(func) == LuaTypes.fun then
            private.func = func
        else
            private.func = function()
                func()
            end
        end
    end

    function public:set_key(event)
        private.event = event
    end

    function public:get()
        connect_signal(widget)
        button_join(public)

        widget.type = "button"
        return widget
    end

    return public
end

return button