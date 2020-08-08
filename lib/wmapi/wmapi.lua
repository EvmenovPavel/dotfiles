local ascreen = require("lib.awful.screen")
local wibox   = require("lib.wibox")

local wmapi   = {}

wmapi.timer   = require("lib.wmapi.timer")
wmapi.markup  = require("lib.wmapi.markup")

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

wmapi.screen_height = ascreen.focused().geometry.height
wmapi.screen_width  = ascreen.focused().geometry.width

return wmapi
