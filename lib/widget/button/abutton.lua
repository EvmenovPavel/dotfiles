local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")


local button    = {}

local function connect_signal(widget, bg_enter, bg_leave, bg_press, bg_release)
    local bg_enter   = bg_enter or beautiful.mouse_enter
    local bg_leave   = bg_leave or beautiful.mouse_leave
    local bg_press   = bg_press or beautiful.button_press
    local bg_release = bg_release or beautiful.button_release

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

local function create(ret)
    ret.widget = wibox.widget({
                                  ret._private.textbox:get(),
                                  layout = wibox.layout.fixed.horizontal,
                              })

    ret.widget:buttons(
            gears.table.join(
                    awful.button(ret._private.key,
                                 ret._private.event,
                                 nil,
                                 ret._private.func)
            )
    )

    ret.widget.type = "button"

    --connect_signal(ret.widget)
end

local function update(ret)

end

function button:init(text, src, key, event_, func)
    local ret             = {}
    --local ct              = wibox.container.background()
    --local ret             = wibox.widget.base.make_widget(ct, "calendar", { enable_properties = true })

    ret._private          = {}

    ret._private.text     = text or "button"
    ret._private.image    = src or ""
    ret._private.key      = key or {}
    ret._private.event    = event_ or event.mouse.button_click_left
    ret._private.func     = func or function()
        log:debug("button:create")
    end
    ret._private.position = false
    ret._private.textbox  = widget:textbox(ret._private.text)

    function ret:set_text(text)
        ret._private.text = text
        ret._private.textbox:set_text(ret._private.text)
    end

    function ret:set_wtext(textbox)
        ret._private.textbox = textbox
    end

    function ret:set_func(func)
        if (type(ret._private.func) == "function") then
            ret._private.func = func
        else
            func = function()
                ret._private.func()
            end
        end
    end

    function ret:set_key(event)
        ret._private.event = event
    end

    function ret:get()
        --create(ret)
        ret.widget = wibox.widget({
                                      ret._private.textbox:get(),
                                      layout = wibox.layout.fixed.horizontal,
                                  })

        ret.widget:buttons(
                gears.table.join(
                        awful.button(ret._private.key,
                                     ret._private.event,
                                     nil,
                                     ret._private.func)
                )
        )

        --ret.widget.type  = "button"

        local bg_enter   = beautiful.mouse_enter
        local bg_leave   = beautiful.mouse_leave
        local bg_press   = beautiful.button_press
        local bg_release = beautiful.button_release

        ret.widget:connect_signal(
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

        ret.widget:connect_signal(
                event.signals.mouse.leave,
                function(self)
                    self.bg = bg_leave
                    if self.old_wibox then
                        self.old_wibox.cursor = self.old_cursor
                        self.old_wibox        = nil
                    end
                end
        )

        ret.widget:connect_signal(
                event.signals.button.press,
                function(self)
                    self.bg = bg_press
                end
        )

        ret.widget:connect_signal(
                event.signals.button.release,
                function(self)
                    self.bg = bg_release
                end
        )

        return ret.widget
    end

    return ret
end

return button
