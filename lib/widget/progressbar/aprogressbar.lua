local wibox       = require("wibox")
local gears       = require("gears")

local progressbar = {}

local ShapeStyle  = {
    rounded_rect           = gears.shape.rounded_rect,
    rounded_bar            = gears.shape.rounded_bar,
    partially_rounded_rect = gears.shape.partially_rounded_rect,
    infobubble             = gears.shape.infobubble,
    rectangular_tag        = gears.shape.rectangular_tag,
    arrow                  = gears.shape.arrow,
    hexagon                = gears.shape.hexagon,
    powerline              = gears.shape.powerline,
    isosceles_triangle     = gears.shape.isosceles_triangle,
    cross                  = gears.shape.cross,
    octogon                = gears.shape.octogon,
    circle                 = gears.shape.circle,
    rectangle              = gears.shape.rectangle,
    parallelogram          = gears.shape.parallelogram,
    losange                = gears.shape.losange,
    pie                    = gears.shape.pie,
    arc                    = gears.shape.arc,
    radial_progress        = gears.shape.radial_progress,
}

function progressbar:init(args)
    local ret          = widget:base("progressbar")

    ret._private       = {}
    ret._private.shape = nil

    local widget       = wibox.widget({
        type   = "progressbar",
        widget = wibox.widget.progressbar,
    })

    function ret:shape(shape)
        ret._private.shape = shape
    end

    return ret
end

return progressbar
