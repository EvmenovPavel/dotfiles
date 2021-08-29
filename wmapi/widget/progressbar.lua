local wibox       = require("wibox")

local progressbar = {}

function progressbar:init(args)
    local args = args or {}

    return wibox.widget({
                            type   = "progressbar",
                            widget = wibox.widget.progressbar,
                        })
end

return setmetatable(progressbar, { __call = function(_, ...)
    return progressbar:init(...)
end })