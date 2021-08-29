local wibox    = require("wibox")

local checkbox = {}

function checkbox:init()
    return wibox.widget({
                            type   = "checkbox",
                            widget = wibox.widget.checkbox,
                        })
end

return setmetatable(checkbox, { __call = function(_, ...)
    return checkbox:init(...)
end })