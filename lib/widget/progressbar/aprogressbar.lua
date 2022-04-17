local wibox       = require("wibox")

local progressbar = {}

function progressbar:init(args)
    local ret  = {}

    local args = args or {}

    ret.widget = wibox.widget({
                                  type   = "progressbar",
                                  widget = wibox.widget.progressbar,
                              })

    return ret
end

return progressbar
