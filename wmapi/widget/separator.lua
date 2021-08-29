local wibox     = require("wibox")

local separator = {}

function separator:inti(args)
    local args = args or {}

    return wibox.widget({
                            type   = "separator",
                            widget = wibox.widget.separator,
                        })
end

return setmetatable(separator, { __call = function(_, ...)
    return separator:init(...)
end })