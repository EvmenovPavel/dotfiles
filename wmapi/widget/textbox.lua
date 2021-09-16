local beautiful = require("beautiful")
local wibox     = require("wibox")

local textbox   = {}

function textbox:create(text, valign, align)
    local ret    = {}

    local text   = text or "TextBox"
    local valign = valign or "center"
    local align  = align or "left"

    ret.widget   = wibox.widget({
                                    type   = "textbox",

                                    text   = text,
                                    font   = beautiful.font,

                                    valign = valign,
                                    align  = align,

                                    widget = wibox.widget.textbox,
                                })

    function ret:set_text(text)
        ret.widget.text = text or ""
    end

    function ret:get()
        return ret.widget
    end

    return ret
end

return textbox