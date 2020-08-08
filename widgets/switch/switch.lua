local awful               = require("lib.awful")
local wibox               = require("lib.wibox")
local clickable_container = require("widgets.clickable-container")
local gears               = require("lib.gears")
local dpi                 = require("lib.beautiful").xresources.apply_dpi

local naughty             = require("naughty")

local PATH_TO_ICONS       = os.getenv("HOME") .. "/.config/awesome/icons/battery/"

local widget              = wibox.widget {
    checked  = false,
    color    = "#ffffff",
    paddings = 2,
    shape    = gears.shape.circle,
    widget   = wibox.widget.switch
}

local widget_button       = clickable_container(wibox.container.margin(widget, dpi(7), dpi(7), dpi(7), dpi(7)))

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
