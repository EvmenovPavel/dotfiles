local wibox     = require("wibox")
local resources = require("resources")

local imagebox  = {}

function imagebox:init(args)
    local args   = args or {}

    local image  = args.image or resources.path .. "/restart-alert.svg"
    local resize = args.resize or true

    return wibox.widget({
                            type          = "imagebox",
                            image         = image,

                            resize        = resize,
                            forced_width  = args.forced_width,
                            forced_height = args.forced_height,

                            widget        = wibox.widget.imagebox,
                        })
end

return setmetatable(imagebox, { __call = function(_, ...)
    return imagebox:init(...)
end })
