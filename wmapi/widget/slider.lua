local wibox  = require("wibox")

local slider = {}

function slider:init(args)
    local args = args or {}

    return wibox.widget({
                            type   = "slider",
                            widget = wibox.widget.slider,
                        })
end

return setmetatable(slider, { __call = function(_, ...)
    return slider:init(...)
end })