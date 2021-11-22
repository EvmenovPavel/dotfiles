local wibox     = require("wibox")
local beautiful = require("beautiful")

local separator = {}

function separator:create(args)
    local ret  = {}

    local args = args or {}

    ret.widget = wibox.widget({
                                  type          = "separator",

                                  orientation   = args.orientation or "horizontal",
                                  forced_height = args.forced_height or 15,
                                  color         = args.color or beautiful.bg_focus,

                                  widget        = wibox.widget.separator,
                              })

    return ret
end

return separator
