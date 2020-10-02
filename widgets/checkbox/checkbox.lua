local awful         = require("awful")
local wibox         = require("wibox")
local gears         = require("gears")
local naughty       = require("naughty")
local dpi           = require("beautiful").xresources.apply_dpi

local PATH_TO_ICONS = os.getenv("HOME") .. "/.config/awesome/icons/battery/"

local widget        = wibox.widget {
    checked  = false,
    color    = "#ffffff",
    paddings = 2,
    shape    = gears.shape.circle,
    widget   = wibox.widget.checkbox
}

local widget_button = capi.wmapi:container(wibox.container.margin(widget, dpi(7), dpi(7), dpi(7), dpi(7)))

function message(str)
    naughty:show({
                     icon  = PATH_TO_ICONS .. "battery.svg",
                     title = "Title: test",
                     text  = "asdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasd"
                 })
end

widget_button:buttons(
        gears.table.join(
                awful.button({}, 1, nil,
                             function()
                                 widget.checked = not widget.checked
                                 message(tostring(widget.checked))
                             end
                )
        )
)

return widget_button
