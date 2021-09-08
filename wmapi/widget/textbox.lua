local beautiful = require("beautiful")
local wibox     = require("wibox")

local textbox   = {}

function textbox:init()
    self.widget = wibox.widget({
                                   type   = "textbox",

                                   font   = beautiful.font,

                                   valign = "center",
                                   align  = "left",

                                   widget = wibox.widget.textbox,
                               })

    return self
end

function textbox:set_text(text)
    local text = text or ""
    self.widget.text = text
end

return setmetatable(textbox, { __call = function()
    return textbox:init()
end })
