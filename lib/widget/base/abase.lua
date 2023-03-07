local beautiful = require("beautiful")

local base = {}

function base:init(type_name)
    local public = {}
    local __private = {}

    ---- Add __tostring method to metatable.
    --local mt = {}
    --local orig_string = tostring(public)
    --mt.__tostring = function()
    --    return string.format("wibox: %s (%s)",
    --            tostring(public._drawable), orig_string)
    --end
    --public = setmetatable(public, mt)

    __private.mouse = {}
    __private.button = {}

    __private.enabled = true
    ---@return boolean
    function public:enabled(status)
        if type(status) == LuaTypes.boolean then
            __private.enabled = status
        end

        return __private.enabled
    end

    __private.visible = false
    ---@return boolean
    function public:visible(visible)
        if type(visible) == LuaTypes.boolean then
            __private.visible = visible
        end

        if __private.widget ~= nil then
            __private.widget:set_visible(__private.visible)
        end

        return __private.visible
    end

    __private.type = type_name or "base"
    ---@return string
    --function public:type(type)
    if type(type_name) == LuaTypes.string and WidgetType[type_name] then
        __private.type = type_name
    end

    --return __private.type
    --end

    __private.geometry = {
        x = 0,
        y = 0,
        width = 0,
        height = 0,
    }
    ---@return function
    function public:geometry()
        local geometry = {}

        function geometry:x(x)
            if type(x) == LuaTypes.number then
                __private.geometry.x = x or 0
            end

            return __private.geometry.x
        end

        function geometry:y(y)
            if type(y) == LuaTypes.number then
                __private.geometry.y = y or 0
            end

            return __private.geometry.y
        end

        function geometry:width(width)
            if type(width) == LuaTypes.number then
                __private.geometry.width = width or 0
            end

            return __private.geometry.width
        end

        function geometry:height(height)
            if type(height) == LuaTypes.number then
                __private.geometry.height = height or 0
            end

            return __private.geometry.height
        end

        return geometry
    end

    __private.minimum_size = {
        width = 0,
        height = 0,
    }
    ---@return function
    function public:minimum_size()
        local minimum_size = {}

        function minimum_size:minimum_size(width, height)
            if type(width) == LuaTypes.number then
                __private.minimum_size.width = width or 0
            end

            if type(height) == LuaTypes.number then
                __private.minimum_size.height = height or 0
            end

            return __private.minimum_size
        end

        function minimum_size:minimum_size_width(width)
            if type(height) == LuaTypes.number then
                __private.minimum_size.width = width or 0
            end

            return __private.minimum_size.width
        end

        function minimum_size:minimum_size_height(height)
            if type(height) == LuaTypes.number then
                __private.minimum_size.height = height or 0
            end

            return __private.minimum_size.height
        end

        return minimum_size
    end

    __private.maximum_size = {
        width = 0,
        height = 0,
    }
    ---@return function
    function public:maximum_size()
        local maximum_size = {}

        function maximum_size:maximum_size(width, height)
            if type(width) == LuaTypes.number then
                __private.maximum_size.width = width or 0
            end

            if type(height) == LuaTypes.number then
                __private.maximum_size.height = height or 0
            end

            return __private.maximum_size
        end

        function maximum_size:maximum_size_width(width)
            if type(width) == LuaTypes.number then
                __private.maximum_size.width = width or 0
            end

            return __private.maximum_size.width
        end

        function maximum_size:maximum_size_height(height)
            if type(height) == LuaTypes.number then
                __private.maximum_size.height = height or 0
            end

            return __private.maximum_size.height
        end

        return maximum_size
    end

    __private.window_title = ""
    ---@return string
    function public:window_title(title)
        if type(title) == LuaTypes.string then
            __private.window_title = title or ""
        end

        return __private.window_title
    end

    __private.font = {
        family = beautiful.font or "Mononoki Nerd Font",
        point_size = 11,
        bold = false,
        italic = false,
        underline = false,
        strikeout = false,
    }
    ---@return function
    function public:font()
        local font = {}

        function font:family(family)
            if type(height) == LuaTypes.string then
                __private.font.family = family or beautiful.font or "Mononoki Nerd Font 10"
            end

            return __private.font.family
        end

        function font:point_size(point_size)
            if type(point_size) == LuaTypes.number then
                __private.font.point_size = point_size or 11
            end

            return __private.font.point_size
        end

        function font:bold(bold)
            if type(bold) == LuaTypes.boolean then
                __private.font.bold = bold or false
            end

            return __private.font.bold
        end

        function font:italic(italic)
            if type(italic) == LuaTypes.boolean then
                __private.font.italic = italic or false
            end

            return __private.font.italic
        end

        function font:underline(underline)
            if type(underline) == LuaTypes.boolean then
                __private.font.underline = underline or false
            end

            return __private.font.underline
        end

        function font:strikeout(strikeout)
            if type(strikeout) == LuaTypes.boolean then
                __private.font.strikeout = strikeout or false
            end

            return __private.font.strikeout
        end

        return font
    end

    __private.window_icon = ""
    ---@return string
    function public:window_icon(icon)
        if type(icon) == LuaTypes.string then
            __private.window_icon = icon or ""
        end

        return __private.window_icon
    end

    __private.shape = nil
    function public:shape(shape)
        if type(icon) == LuaTypes.func then
            __private.shape = shape
        end

        return __private.shape
    end

    __private.widget = nil
    function public:set_widget(widget, func)
        __private.widget = widget

        if type(func) == LuaTypes.func then
            __private.update_widget = func
        end
    end

    __private.update_widget = nil
    function public:update_widget(...)
        if __private.widget ~= nil and __private.update_widget then
            __private.update_widget(...)
        end
    end

    function public:mouse()
        local mouse = {}

        -- "mouse::enter"
        function mouse:enter(func)
            if __private.widget ~= nil and type(func) == LuaTypes.func then
                __private.widget:connect_signal(event.signals.mouse.enter, func)
            end
        end

        -- "mouse::leave"
        function mouse:leave(func)
            if __private.widget ~= nil and type(func) == LuaTypes.func then
                __private.widget:connect_signal(event.signals.mouse.leave, func)
            end
        end

        -- "mouse::press"
        function mouse:press(func)
            if __private.widget ~= nil and type(func) == LuaTypes.func then
                __private.widget:connect_signal(event.signals.mouse.press, func)
            end
        end

        -- "mouse::release"
        function mouse:release(func)
            if __private.widget ~= nil and type(func) == LuaTypes.func then
                __private.widget:connect_signal(event.signals.mouse.release, func)
            end
        end

        -- "mouse::move"
        function mouse:move(func)
            if __private.widget ~= nil and type(func) == LuaTypes.func then
                __private.widget:connect_signal(event.signals.mouse.move, func)
            end
        end

        return mouse
    end

    function public:button()
        local button = {}

        function button:press(func)
            if __private.widget ~= nil and type(func) == LuaTypes.func then
                __private.widget:connect_signal(event.signals.button.press, func)
            end
        end

        function button:release(func)
            if __private.widget ~= nil and type(func) == LuaTypes.func then
                __private.widget:connect_signal(event.signals.button.release, func)
            end
        end

        return button
    end

    return public
end

--return base
return setmetatable(base, { __call = function()
    return base
end })
