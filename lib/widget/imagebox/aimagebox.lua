local wibox    = require("wibox")

local imagebox = {}

function imagebox:init()
    local ret               = wmapi.widget:base("imagebox")

    local __private         = {}

    __private.image         = ""
    __private.resize        = true
    __private.forced_width  = nil
    __private.forced_height = nil
    __private.clip_shape    = nil

    local widget            = wibox.widget({
        image         = __private.image,
        resize        = __private.resize,
        forced_width  = __private.forced_width,
        forced_height = __private.forced_height,
        widget        = wibox.widget.imagebox(),
    })
    ret:set_widget(widget)

    local function update_widget()
        widget:set_image(__private.image)
        widget:set_resize(__private.resize)

        widget.forced_width  = __private.forced_width
        widget.forced_height = __private.forced_width
    end

    function ret:image(image)
        if type(image) == LuaTypes.string then
            if not wmapi:is_file(image) then
                __private.image = image or nil
                update_widget()
            end
        end

        return __private.image
    end

    function ret:width(width)
        if type(width) == LuaTypes.number then
            __private.forced_width = width
            update_widget()
        end

        return __private.forced_width
    end

    function ret:height(height)
        if type(height) == LuaTypes.number then
            __private.forced_height = height
            update_widget()
        end

        return __private.forced_height
    end

    function ret:resize(resize)
        if type(resize) == LuaTypes.boolean then
            __private.resize = resize
            update_widget()
        end

        return __private.resize
    end

    function ret:clip_shape(clip_shape, ...)
        __private.clip_shape = clip_shape or true
        update_widget()
    end

    function imagebox:draw(cr, width, height)

    end

    function imagebox:fit(width, height)

    end

    function ret:get()
        update_widget()
        return widget
    end

    return ret
end

return setmetatable(imagebox, { __call = function()
    return imagebox
end })
