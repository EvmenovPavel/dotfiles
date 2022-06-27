local wibox   = require("wibox")

local textbox = {}

function textbox:init(text)
    local public          = wmapi:widget():base("textbox")

    local private         = {}

    --Set the text of the textbox (with Pango markup).
    private.markup        = ""
    --Set a textbox' text.
    private.text          = (type(text) == LuaTypes.string) and text or "TextBox"
    --Set a textbox' ellipsize mode.
    private.ellipsize     = "start"
    --Set a textbox' wrap mode.
    private.wrap          = "char"
    --The textbox' vertical alignment
    --Where should the textbox be drawn? “top”, “center” or “bottom”
    private.valign        = "center"
    --Set a textbox' horizontal alignment.
    private.align         = "center"
    --Set a textbox' font
    private.font          = public:font():family()
    --Force a widget height.
    private.forced_height = nil
    --Force a widget width.
    private.forced_width  = nil
    --The widget opacity (transparency).
    private.opacity       = 1
    --The widget visibility.
    private.visible       = true

    local widget          = wibox.widget.textbox()

    local function update()
        widget:set_markup(private.markup)
        widget:set_text(private.text)

        widget:set_ellipsize(private.ellipsize)
        widget:set_wrap(private.wrap)
        widget:set_valign(private.valign)
        widget:set_align(private.align)

        widget:set_font(private.font)

        widget:set_forced_width(private.forced_width)
        --widget.forced_width = private.forced_width
        widget:set_forced_height(private.forced_height)
        --widget.forced_height = private.forced_height

        widget:set_opacity(private.opacity)
        widget:set_visible(private.visible)
    end

    function public:markup(markup)
        if type(markup) == LuaTypes.string then
            private.markup = markup
            private.text   = ""
        end

        update()

        return private.markup
    end

    function public:text(text)
        if type(text) == LuaTypes.string then
            private.text   = text
            private.markup = ""
        end

        update()

        return private.text
    end

    function public:wrap(wrap)
        if type(wrap) == LuaTypes.string then
            if wrap == "word" or wrap == "char" or wrap == "word_char" then
                private.wrap = wrap

                return private.wrap
            end
        end

        local wrap = {}

        function wrap:word()
            private.wrap = "word"
            return private.wrap
        end
        function wrap:char()
            private.wrap = "char"
        end
        function wrap:word_char()
            private.wrap = "word_char"
        end

        return wrap
    end

    function public:valign(valign)
        if type(valign) == LuaTypes.string then
            if valign == "top" or valign == "center" or valign == "bottom" then
                private.valign = valign
                return private.valign
            end
        end

        local valign = {}

        function valign:top()
            private.valign = "top"
            return private.valign
        end
        function valign:center()
            private.valign = "center"
            return private.valign
        end
        function valign:bottom()
            private.valign = "bottom"
            return private.valign
        end

        return valign
    end

    function public:ellipsize(ellipsize)
        if type(ellipsize) == LuaTypes.string then
            if ellipsize == "start" or ellipsize == "middle" or ellipsize == "end" then
                private.ellipsize = ellipsize
                return private.ellipsize
            end
        end

        local ellipsize = {}

        function ellipsize:start()
            private.ellipsize = "start"
        end
        function ellipsize:middle()
            private.ellipsize = "middle"
        end
        function ellipsize:the_end()
            private.ellipsize = "end"
        end

        return ellipsize
    end

    function public:align(align)
        if type(align) == LuaTypes.string then
            if align == "left" or align == "center" or align == "right" then
                private.align = align
                return private.align
            end
        end

        local align = {}
        function align:left()
            private.align = "left"
            return private.align
        end
        function align:center()
            private.align = "center"
            return private.align
        end
        function align:right()
            private.align = "right"
            return private.align
        end

        return align
    end

    function public:font(font)
        if type(font) == LuaTypes.string then
            private.font = font
        end

        return private.font
    end

    function public:forced_width(forced_width)
        if type(forced_width) == LuaTypes.number then
            private.forced_width = forced_width
        end

        return private.forced_width
    end

    function public:forced_height(forced_height)
        if type(forced_height) == LuaTypes.number then
            private.forced_height = forced_height
        end

        return private.forced_height
    end

    function public:opacity(opacity)
        if type(opacity) == LuaTypes.string then
            private.opacity = opacity
        end

        return private.opacity
    end

    function public:visible(visible)
        if type(visible) == LuaTypes.boolean then
            private.visible = visible
        end

        return private.visible
    end

    --Signals
    --When the layout (size) change.
    --widget:emit_signal("widget::layout_changed",
    --                   function()
    --                   end)
    --When the widget content changed.
    --widget:emit_signal("widget::redraw_needed",
    --                   function()
    --                   end)

    --When a mouse button is pressed over the widget.
    widget:connect_signal("button::press",
                          function()
                          end)

    --When a mouse button is released over the widget.
    widget:connect_signal("button::release",
                          function()
                          end)

    --When the mouse enter a widget.
    widget:connect_signal("mouse::enter",
                          function()
                          end)

    --When the mouse leave a widget.
    widget:connect_signal("mouse::leave",
                          function()
                          end)

    function public:get()
        return widget
    end

    return public
end

return textbox
