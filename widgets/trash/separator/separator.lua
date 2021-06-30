local wibox     = require("wibox")
local dpi       = require("beautiful").xresources.apply_dpi

local separator = wibox.widget {
    orientation   = "horizontal",
    forced_height = dpi(6),
    opacity       = 0.20,
    widget        = wibox.widget.separator
}

return separator
