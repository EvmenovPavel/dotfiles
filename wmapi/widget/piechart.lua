local wibox    = require("wibox")

local piechart = {}

function piechart:create(args)
    local args = args or {}

    local ret  = {}

    ret.widget = wibox.widget({
                                  type   = "piechart",
                                  widget = wibox.widget.piechart,
                              })

    return ret
end

return piechart
