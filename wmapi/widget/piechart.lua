local wibox    = require("wibox")

local piechart = {}

function piechart:init(args)
    local args = args or {}

    return wibox.widget({
                            type   = "piechart",
                            widget = wibox.widget.piechart,
                        })
end

return setmetatable(piechart, { __call = function(_, ...)
    return piechart:init(...)
end })
