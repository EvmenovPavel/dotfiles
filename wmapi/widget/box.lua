local wibox = require("wibox")
local gears = require("gears")

local box   = {}

function box:create(args)
    local ret  = {}

    local args = args or {}

    ret.widget = wibox.widget({
                                  type   = "box",

                                  shape  = function(cr, width, height)
                                      gears.shape.rectangle(cr, args.width or width, args.height or height)
                                  end,
                                  widget = wibox.widget.checkbox,
                              })

    function ret:get()
        return ret.widget
    end

    return ret
end

return box
