local beautiful = require("beautiful")
local wibox     = require("wibox")

local textbox   = {}

function textbox:create(argc)
    local ret  = {}

    ret.widget = wibox.widget({
                                  type   = "textbox",

                                  font   = beautiful.font,

                                  valign = "center",
                                  align  = "left",

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