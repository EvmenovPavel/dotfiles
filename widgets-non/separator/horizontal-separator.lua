local wibox                = require("lib.wibox")
local dpi                  = require("lib.beautiful").xresources.apply_dpi

local horizontal_separator = wibox.widget {
    orientation   = "horizontal",
    forced_height = dpi(16),
    opacity       = 0.20,
    widget        = wibox.widget.separator
}

return horizontal_separator
