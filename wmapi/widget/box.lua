local wibox = require("wibox")
local gears = require("gears")

local box   = {}

function box:create(width, height)
    local ret    = {}

    local width  = width or nil
    local height = height or nil

    ret.widget   = wibox.widget({
                                    type   = "box",

                                    shape  = function(cr, width_, height_)
                                        gears.shape.rectangle(cr, width or width_, height or height_)
                                    end,

                                    widget = wibox.widget.checkbox,
                                })

    function ret:get()
        return ret.widget
    end

    return ret
end

return box
