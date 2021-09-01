local wibox     = require("wibox")

local separator = {}

function separator:inti(args)
    local args = args or {}

    return wibox.widget({
                            type          = "separator",

                            orientation   = args.orientation or "horizontal",
                            forced_height = args.forced_height or 15,
                            color         = args.color or beautiful.bg_focus,

                            widget        = wibox.widget.separator,
                        })
end

return setmetatable(separator, { __call = function(_, ...)
    return separator:init(...)
end })
