local wibox    = require("wibox")

local imagebox = {}

function imagebox:init(argc)
    local ret                  = {}

    ret._private               = {}

    local argc                 = argc or {}

    ret._private.image         = argc.image or nil
    ret._private.resize        = argc.resize or true
    ret._private.forced_width  = argc.forced_width or nil
    ret._private.forced_height = argc.forced_height or nil

    function ret:set_image(image)
        ret._private.image = image or nil
    end

    function ret:set_width(width)
        ret._private.forced_width = width
    end

    function ret:set_height(height)
        ret._private.forced_height = height
    end

    function ret:set_resize(resize)
        ret._private.resize = resize or true
    end

    local function create()
        ret.widget      = wibox.widget({
                                           image         = ret._private.image,

                                           resize        = ret._private.resize,
                                           forced_width  = ret._private.forced_width,
                                           forced_height = ret._private.forced_height,

                                           widget        = wibox.widget.imagebox(),
                                       })

        ret.widget.type = "imagebox"

        return ret.widget
    end

    function ret:get()
        return create()
    end

    return ret
end

return imagebox