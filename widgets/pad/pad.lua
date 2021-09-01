local wibox = require("wibox")

local pad   = {}

function pad:init(size)
    local size = size or 3
    local str  = ""
    for i = 1, size do
        str = str .. " "
    end

    local widget = wibox.widget.textbox(str)
    return widget
end

return setmetatable(pad, { __call = function(_, ...)
    return pad:init(...)
end })
