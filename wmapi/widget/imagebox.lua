local wibox    = require("wibox")

local imagebox = {}

function imagebox:init(args)
    local args = args or {}

    return wibox.widget(
            {
                type   = "imagebox",
                widget = wibox.widget.imagebox,
                image  = args.image,
            })
end

return setmetatable(imagebox, { __call = function(_, ...)
    return imagebox:init(...)
end })