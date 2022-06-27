local beautiful = require("beautiful")
local wibox     = require("wibox")

local base      = {}

function base:init(name_type)
    local public    = {}
    local private   = {}

    --_private.widget = wibox.widget({ widget = wibox.container.background() })
    --
    --function set_widget()
    --    for i = 1, select("#", ...) do
    --        local w = select(i, ...)
    --        if w then
    --            res:add(w)
    --        end
    --    end
    --
    --    _private.widget:set_widget(res)
    --end

    private.enabled = true
    ---@return boolean
    function public:enabled(status)
        if type(status) == LuaTypes.boolean then
            private.enabled = status
        end

        return private.enabled
    end

    private.visible = true
    ---@return boolean
    function public:visible(visible)
        if type(visible) == LuaTypes.boolean then
            private.visible = visible
        end

        return private.visible
    end

    private.name_type = name_type or "base"
    ---@return string
    function public:type()
        return private.name_type
    end

    private.geometry = {
        x      = 0,
        y      = 0,
        width  = 0,
        height = 0,
    }
    function public:geometry()
        local geometry = {}

        function geometry:x(x)
            if type(x) == LuaTypes.number then
                private.geometry.x = x or 0
            end

            return private.geometry.x
        end

        function geometry:y(y)
            if type(y) == LuaTypes.number then
                private.geometry.y = y or 0
            end

            return private.geometry.y
        end

        function geometry:width(width)
            if type(width) == LuaTypes.number then
                private.geometry.width = width or 0
            end

            return private.geometry.width
        end

        function geometry:height(height)
            if type(height) == LuaTypes.number then
                private.geometry.height = height or 0
            end

            return private.geometry.height
        end

        return geometry
    end

    private.minimum_size = {
        width  = 0,
        height = 0,
    }
    function public:minimum_size()
        local minimum_size = {}

        function minimum_size:minimum_size(width, height)
            if type(width) == LuaTypes.number then
                private.minimum_size.width = width or 0
            end

            if type(height) == LuaTypes.number then
                private.minimum_size.height = height or 0
            end

            return private.minimum_size
        end

        function minimum_size:minimum_size_width(width)
            if type(height) == LuaTypes.number then
                private.minimum_size.width = width or 0
            end

            return private.minimum_size.width
        end

        function minimum_size:minimum_size_height(height)
            if type(height) == LuaTypes.number then
                private.minimum_size.height = height or 0
            end

            return private.minimum_size.height
        end

        return minimum_size
    end

    -------------------------------------------------------------------------------------------------------------------
    private.maximum_size = {
        width  = 0,
        height = 0,
    }
    function public:maximum_size()
        local maximum_size = {}

        function maximum_size:maximum_size(width, height)
            if type(width) == LuaTypes.number then
                private.maximum_size.width = width or 0
            end

            if type(height) == LuaTypes.number then
                private.maximum_size.height = height or 0
            end

            return private.maximum_size
        end

        function maximum_size:maximum_size_width(width)
            if type(width) == LuaTypes.number then
                private.maximum_size.width = width or 0
            end

            return private.maximum_size.width
        end

        function maximum_size:maximum_size_height(height)
            if type(height) == LuaTypes.number then
                private.maximum_size.height = height or 0
            end

            return private.maximum_size.height
        end

        return maximum_size
    end

    private.window_title = ""
    function public:window_title(title)
        if type(title) == LuaTypes.string then
            private.window_title = title or ""
        end

        return private.window_title
    end

    private.font = {
        family     = beautiful.font or "Mononoki Nerd Font",
        point_size = 11,
        bold       = false,
        italic     = false,
        underline  = false,
        strikeout  = false,
    }
    function public:font()
        local font = {}

        function font:family(family)
            if type(height) == LuaTypes.string then
                private.font.family = family or beautiful.font or "Mononoki Nerd Font 10"
            end

            return private.font.family
        end

        function font:point_size(point_size)
            if type(point_size) == LuaTypes.number then
                private.font.point_size = point_size or 11
            end

            return private.font.point_size
        end

        function font:bold(bold)
            if type(bold) == LuaTypes.boolean then
                private.font.bold = bold or false
            end

            return private.font.bold
        end

        function font:italic(italic)
            if type(italic) == LuaTypes.boolean then
                private.font.italic = italic or false
            end

            return private.font.italic
        end

        function font:underline(underline)
            if type(underline) == LuaTypes.boolean then
                private.font.underline = underline or false
            end

            return private.font.underline
        end

        function font:strikeout(strikeout)
            if type(strikeout) == LuaTypes.boolean then
                private.font.strikeout = strikeout or false
            end

            return private.font.strikeout
        end

        return font
    end

    private.window_icon = ""
    function public:window_icon(icon)
        if type(icon) == LuaTypes.string then
            private.window_icon = icon or ""
        end

        return private.window_icon
    end
    function public:window_icon()
        return private.window_icon
    end

    private.shape = nil
    function public:shape(shape)
        if type(icon) == LuaTypes.fun then
            private.shape = shape
        end

        return private.shape
    end

    return public
end

return base