local wibox = require("wibox")

local textbox = {}

function textbox:init()
    local ret = wmapi.widget:base("textbox")

    local __private = {}

    --Set the text of the textbox (with Pango markup).
    __private.markup = "textbox"
    --Set a textbox' text.
    __private.text = "textbox"
    --Set a textbox' ellipsize mode.
    __private.ellipsize = "start"
    --Set a textbox' wrap mode.<
    __private.wrap = "char"
    --The textbox' vertical alignment
    --Where should the textbox be drawn? “top”, “center” or “bottom”
    __private.valign = "center"
    --Set a textbox' horizontal alignment.
    __private.align = "center"
    --Set a textbox' font
    __private.family = ret:font():family()
    --Force a widget height.
    __private.forced_height = nil
    --Force a widget width.
    __private.forced_width = nil
    --The widget opacity (transparency).
    __private.opacity = 1

    --The widget
    local widget = wibox.widget.textbox()
    ret:set_widget(widget, function()
        widget:set_markup(__private.markup)
        widget:set_text(__private.text)

        widget:set_ellipsize(__private.ellipsize)
        widget:set_wrap(__private.wrap)
        widget:set_valign(__private.valign)
        widget:set_align(__private.align)

        widget:set_font(__private.family)

        widget:set_forced_width(__private.forced_width)
        --widget.forced_width = private.forced_width
        widget:set_forced_height(__private.forced_height)
        --widget.forced_height = private.forced_height

        widget:set_opacity(__private.opacity)
    end)

    ret:update_widget()

    function ret:markup(markup)
        if type(markup) == LuaTypes.string then
            __private.markup = markup
            __private.text = ""
        end

        ret:update_widget()

        return __private.markup
    end

    function ret:text(text)
        if type(text) == LuaTypes.string then
            __private.text = text
            __private.markup = ""
        end

        ret:update_widget()

        return __private.text
    end

    function ret:wrap(wrap)
        if type(wrap) == LuaTypes.string then
            if wrap == "word" or wrap == "char" or wrap == "word_char" then
                __private.wrap = wrap
                return __private.wrap
            end
        end

        local _wrap = {}

        function _wrap:word()
            __private.wrap = "word"
            return __private.wrap
        end
        function _wrap:char()
            __private.wrap = "char"
        end
        function _wrap:word_char()
            __private.wrap = "word_char"
        end

        return _wrap
    end

    function ret:valign(valign)
        if type(valign) == LuaTypes.string then
            if valign == "top" or valign == "center" or valign == "bottom" then
                __private.valign = valign
                return __private.valign
            end
        end

        local _valign = {}

        function _valign:top()
            __private.valign = "top"
            return __private.valign
        end
        function _valign:center()
            __private.valign = "center"
            return __private.valign
        end
        function _valign:bottom()
            __private.valign = "bottom"
            return __private.valign
        end

        return _valign
    end

    function ret:ellipsize(ellipsize)
        if type(ellipsize) == LuaTypes.string then
            if ellipsize == "start" or ellipsize == "middle" or ellipsize == "end" then
                __private.ellipsize = ellipsize
                return __private.ellipsize
            end
        end

        local _ellipsize = {}

        function _ellipsize:start()
            __private.ellipsize = "start"
        end
        function _ellipsize:middle()
            __private.ellipsize = "middle"
        end
        function _ellipsize:the_end()
            __private.ellipsize = "end"
        end

        return _ellipsize
    end

    function ret:align(align)
        if type(align) == LuaTypes.string then
            if align == "left" or align == "center" or align == "right" then
                __private.align = align
                return __private.align
            end
        end

        local _align = {}
        function _align:left()
            __private.align = "left"
            return __private.align
        end
        function _align:center()
            __private.align = "center"
            return __private.align
        end
        function _align:right()
            __private.align = "right"
            return __private.align
        end

        return _align
    end

    function ret:forced_width(forced_width)
        if type(forced_width) == LuaTypes.number then
            __private.forced_width = forced_width
        end

        return __private.forced_width
    end

    function ret:forced_height(forced_height)
        if type(forced_height) == LuaTypes.number then
            __private.forced_height = forced_height
        end

        return __private.forced_height
    end

    function ret:opacity(opacity)
        if type(opacity) == LuaTypes.number then
            __private.opacity = opacity
        end

        return __private.opacity
    end

    function ret:get()
        ret:update_widget()
        return widget
    end

    return ret
end

return setmetatable(textbox, { __call = function()
    return textbox
end })
