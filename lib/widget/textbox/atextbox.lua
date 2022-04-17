local beautiful = require("beautiful")
local wibox     = require("wibox")

local textbox   = {}

-- You can control the place of wrapping: wrap_mode can be set to "word", "char", or "word_char".
-- You can also control the vertical alignment: valign can be set to "top", "center", and "bottom". (I think center is the default.)

function textbox:init(text, valign, align)
    local ret    = {}

    local text   = text or "TextBox"
    local valign = valign or "center"
    local align  = align or "center"

    ret.widget   = wibox.widget({
                                    type   = "textbox",

                                    text   = text,
                                    font   = beautiful.font,

                                    valign = valign,
                                    align  = align,
                                    --wrap = 'word',
                                    
                                    widget = wibox.widget.textbox,
                                })

    function ret:set_text(text)
        ret.widget.text = text or ""
    end

    function ret:get()
        self.widget.type = "textbox"
        return self.widget
    end

    return ret
end

return textbox
