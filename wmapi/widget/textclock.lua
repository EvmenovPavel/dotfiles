local wibox     = require("wibox")

local textclock = {}

function textclock:init(args)
    local args = args or {}

    return wibox.widget({
                            widget = wibox.widget.textclock,
                            type   = "textclock"
                        })
end

return setmetatable(textclock, { __call = function(_, ...)
    return textclock:init(...)
end })
