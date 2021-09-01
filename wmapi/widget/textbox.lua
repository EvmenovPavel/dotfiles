local beautiful = require("beautiful")
local wibox     = require("wibox")

local textbox   = {}

function textbox:init(args)
    local args = args or {}

    return wibox.widget {
        type         = "textbox",

        markup       = args.markup,
        text         = args.text,

        font         = beautiful.font,

        valign       = args.valign or "center",
        align        = args.align or "left",

        forced_width = args.forced_width or 50,

        widget       = wibox.widget.textbox,
    }
end

return setmetatable(textbox, { __call = function(_, ...)
    return textbox:init(...)
end })
