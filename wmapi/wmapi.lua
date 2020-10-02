local ascreen = require("awful.screen")
local wibox   = require("wibox")
local gears   = require("gears")

local wmapi   = {}

wmapi.timer   = require("wmapi.timer")
wmapi.markup  = require("wmapi.markup")

function wmapi:base()
    return wibox.widget({
                            widget = wibox.widget.base,
                            type   = "base"
                        })
end

function wmapi:calendar()
    return wibox.widget({
                            widget = wibox.widget.calendar,
                            type   = "calendar"
                        })
end

function wmapi:checkbox()
    return wibox.widget({
                            widget = wibox.widget.checkbox,
                            type   = "checkbox"
                        })
end

function wmapi:graph()
    return wibox.widget({
                            widget = wibox.widget.graph,
                            type   = "graph"
                        })
end

function wmapi:imagebox(image)
    return wibox.widget(
            {
                widget = wibox.widget.imagebox,
                type   = "imagebox",
                image  = image,
            })
end

function wmapi:piechart()
    return wibox.widget({
                            widget = wibox.widget.piechart,
                            type   = "piechart"
                        })
end

function wmapi:progressbar()
    return wibox.widget({
                            widget = wibox.widget.progressbar,
                            type   = "progressbar"
                        })
end

function wmapi:separator()
    return wibox.widget({
                            widget = wibox.widget.separator,
                            type   = "separator"
                        })
end

function wmapi:slider()
    return wibox.widget({
                            widget = wibox.widget.slider,
                            type   = "slider"
                        })
end

function wmapi:systray()
    return wibox.widget({
                            widget = wibox.widget.systray,
                            type   = "systray"
                        })
end

function wmapi:textbox(markup)
    return wibox.widget({
                            widget = wibox.widget.textbox,
                            type   = "textbox",
                            markup = markup
                        })
end

function wmapi:textclock()
    return wibox.widget({
                            widget = wibox.widget.textclock,
                            type   = "textclock"
                        })
end

function wmapi:pad(size)
    local str = ""
    for i = 1, size do
        str = str .. " "
    end

    local widget = wibox.widget.textbox(str)
    return widget
end

function wmapi:tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

function wmapi:display_primary(s)
    if s == capi.screen.primary then
        return true
    end

    return false
end

function wmapi:display_index(s)
    for i = 1, capi.screen.count() do
        if s == capi.screen[i] then
            return i
        end
    end

    return 1
end

function wmapi:update(timeout, callback)
    local timeout  = timeout or 0.1
    local callback = callback or nil

    if callback == nil then
        return nil
    end

    return gears.timer {
        timeout   = timeout,
        call_now  = true,
        autostart = true,
        callback  = callback
    }
end

wmapi.screen_height = ascreen.focused().geometry.height
wmapi.screen_width  = ascreen.focused().geometry.width

function wmapi:container(widget)
    local container = wibox.widget {
        widget,
        widget = wibox.container.background
    }
    local old_cursor, old_wibox

    container:connect_signal(
            "mouse::enter",
            function()
                container.bg = "#ffffff11"
                local w      = _G.mouse.current_wibox
                if w then
                    old_cursor, old_wibox = w.cursor, w
                    w.cursor              = "hand1"
                end
            end
    )

    container:connect_signal(
            "mouse::leave",
            function()
                container.bg = "#ffffff00"
                if old_wibox then
                    old_wibox.cursor = old_cursor
                    old_wibox        = nil
                end
            end
    )

    container:connect_signal(
            "button::press",
            function()
                container.bg = "#ffffff22"
            end
    )

    container:connect_signal(
            "button::release",
            function()
                container.bg = "#ffffff11"
            end
    )

    return container
end

return wmapi
