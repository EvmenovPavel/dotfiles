local wibox     = require("wibox")
local resources = require("resources")

local imagebox  = {}

function imagebox:create(argc)
    local ret           = {}

    local argc          = argc or {}
    local image         = argc.image or resources.path .. "/restart-alert.svg"
    local resize        = argc.resize or true
    local forced_width  = argc.forced_width or nil
    local forced_height = argc.forced_height or nil

    ret.widget          = wibox.widget({
                                           type          = "imagebox",
                                           image         = image,

                                           resize        = resize,
                                           forced_width  = forced_width,
                                           forced_height = forced_height,

                                           widget        = wibox.widget.imagebox,
                                       })

    function ret:set_image(src)
        ret.widget.image = src or image
    end

    function ret:set_resize(resize_)
        ret.widget.resize = resize_ or resize
    end

    function ret:get()
        return ret.widget
    end

    return ret
end

return imagebox