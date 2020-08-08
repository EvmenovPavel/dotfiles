local awful               = require("lib.awful")
local wibox               = require("lib.wibox")
local clickable_container = require("widgets.clickable-container")
local gears               = require("lib.gears")
local dpi                 = require("lib.beautiful").xresources.apply_dpi

local PATH_TO_ICONS       = os.getenv("HOME") .. "/.config/awesome/icons/"

local widget              = wibox.widget {
    {
        id     = "icon",
        image  = PATH_TO_ICONS .. "restart-alert.svg",
        widget = wibox.widget.imagebox,
        resize = true
    },
    layout = wibox.layout.fixed.horizontal
}

local widget_button       = clickable_container(wibox.container.margin(widget, dpi(7), dpi(7), dpi(7), dpi(7)))
widget_button:buttons(
        gears.table.join(
                awful.button({}, 1, nil,
                             function()
                                 awesome.restart()
                             end
                )
        )
)

return widget_button
