local wibox     = require("wibox")

local textclock = {}

function textclock:create(args)
    local ret  = {}

    local args = args or {}

    ret.widget = wibox.widget({
                                  widget = wibox.widget.textclock,
                                  type   = "textclock"
                              })

    return ret
end

return textclock
