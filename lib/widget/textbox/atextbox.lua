local wibox   = require("wibox")

local textbox = {}

local function is_empty(value, type)

end

function textbox:init()
    local ret               = wmapi.widget:base("textbox")

    local __private         = {}

    --Set the text of the textbox (with Pango markup).
    __private.markup        = ""
    --Set a textbox' text.
    __private.text          = "textbox"
    --Set a textbox' ellipsize mode.
    __private.ellipsize     = "start"
    --Set a textbox' wrap mode.<
    __private.wrap          = "char"
    --The textbox' vertical alignment
    --Where should the textbox be drawn? “top”, “center” or “bottom”
    __private.valign        = "center"
    --Set a textbox' horizontal alignment.
    __private.align         = "center"
    --Set a textbox' font
    __private.family        = ret:font():family()
    --Force a widget height.
    __private.forced_height = nil
    --Force a widget width.
    __private.forced_width  = nil
    --The widget opacity (transparency).
    __private.opacity       = 1

    --The widget
    local widget            = wibox.widget.textbox()
    ret:set_widget(widget, function()
        if not wmapi:is_empty(__private.markup) then
            widget:set_markup(__private.markup)
        end

        if not wmapi:is_empty(__private.text) then
            widget:set_text(__private.text)
        end

        widget:set_ellipsize(__private.ellipsize)
        widget:set_wrap(__private.wrap)
        widget:set_valign(__private.valign)
        widget:set_align(__private.align)

        widget:set_font(__private.family)

        widget:set_forced_width(__private.forced_width)
        widget:set_forced_height(__private.forced_height)

        widget:set_opacity(__private.opacity)
    end)

    ret:update_widget()

    function ret:markup(markup)
        if type(markup) == LuaTypes.string and not wmapi:is_empty(markup) then
            __private.text   = ""
            __private.markup = markup
        end

        return __private.markup
    end

    function ret:text(text)
        if type(text) == LuaTypes.string and not wmapi:is_empty(text) then
            __private.markup = ""
            __private.text   = text
        end

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
        end
        function _valign:center()
            __private.valign = "center"
        end
        function _valign:bottom()
            __private.valign = "bottom"
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

    function ret:family(family)
        if type(family) == LuaTypes.string then
            __private.family = family
        end

        return __private.family
    end

    function ret:font(font)
        if type(font) == LuaTypes.string then
            __private.family = font
        end

        return __private.family
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

--[[
    :set_text(text) - устанавливает текст для виджета.
    :get_text() - возвращает текущий текст виджета.
    :set_align(align) - устанавливает выравнивание текста в виджете. Значение align должно быть одним из следующих: "left", "center" или "right".
    :set_valign(valign) - устанавливает вертикальное выравнивание текста в виджете. Значение valign должно быть одним из следующих: "top", "center" или "bottom".
    :set_font(font) - устанавливает шрифт для текста виджета.
    :set_markup(markup) - устанавливает текст с использованием формата Pango markup. Формат Pango markup позволяет задавать различные свойства текста, такие как цвет, размер шрифта, стиль и т.д.
    :set_markup_preformatted(markup) - устанавливает текст с использованием формата Pango markup, при этом игнорирует пробельные символы и сохраняет оригинальный форматированный текст.
    :set_max_width(width) - устанавливает максимальную ширину виджета. Если текст в виджете превышает установленную ширину, то он обрезается.
    :set_max_height(height) - устанавливает максимальную высоту виджета. Если текст в виджете превышает установленную высоту, то он обрезается.
    :set_wrap_mode(mode) - устанавливает режим переноса текста в виджете. Значение mode должно быть одним из следующих: "none", "char", "word", "word_char".
    :set_ellipsize(ellipsize) - устанавливает тип многоточия, которое используется при обрезании текста в виджете. Значение ellipsize должно быть одним из следующих: "none", "start", "middle", "end".
    :set_single_line(single_line) - устанавливает режим отображения текста в виджете. Если single_line установлен в true, то текст будет отображаться в одну строку без переноса.
    :set_color(color) - устанавливает цвет текста в виджете.
    :set_bg(bg) - устанавливает фоновый цвет виджета.
    :set_fg(fg) - устанавливает цвет текста в виджете.
    :set_underline(underline) - устанавливает стиль подчеркивания для текста в виджете. Если параметр underline установлен в true, то текст будет подчеркнут. Если underline установлен в false, то подчеркивание будет отключено.
    :set_strikethrough(strikethrough) - устанавливает стиль перечеркивания для текста в виджете. Если strikethrough установлен в true, то текст будет перечеркнут. Если strikethrough установлен в false, то перечеркивание будет отключено.
    :set_font_size(size) - устанавливает размер шрифта для текста в виджете.
    :set_font_family(family) - устанавливает семейство шрифта для текста в виджете.
    :set_font_slant(slant) - устанавливает стиль наклона шрифта для текста в виджете. Значение slant должно быть одним из следующих: "normal", "italic" или "oblique".
    :set_font_weight(weight) - устанавливает насыщенность шрифта для текста в виджете. Значение weight должно быть одним из следующих: "ultralight", "light", "normal", "medium", "semibold", "bold", "ultrabold" или "heavy".
    :set_opacity(opacity) - устанавливает прозрачность виджета. Значение opacity должно быть числом от 0 до 1, где 0 - виджет полностью прозрачен, а 1 - виджет полностью непрозрачен.
    :fit(width, height) - изменяет размеры виджета так, чтобы он соответствовал указанным размерам width и height.
    :set_forced_width(width) - устанавливает принудительную ширину виджета.
    :set_forced_height(height) - устанавливает принудительную высоту виджета.
    :get_preferred_size() - возвращает предпочтительные размеры виджета.
    :get_pixel_size() - возвращает текущий размер виджета в пикселях.
]]