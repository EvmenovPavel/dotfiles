local wibox = require("wibox")
local gears = require("gears")

local box   = {}

function box:init(args)
    local args = args or {}

    return wibox.widget({
                            type   = "box",

                            shape  = function(cr, width, height)
                                gears.shape.rectangle(cr, args.width or width, args.height or height)
                            end,
                            widget = wibox.widget.checkbox,
                        })
end

return setmetatable(box, { __call = function(_, ...)
    return box:init(...)
end })
