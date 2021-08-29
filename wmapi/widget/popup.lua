local beautiful  = require("beautiful")
local gears      = require("gears")
local awful      = require("awful")
local wibox      = require("wibox")

local popup      = {}

local popup_list = {}

function popup:init(args)
    local args   = args or {}

    local widget = wibox.widget {
        {
            widget = args.widget or {},
            layout = wibox.layout.fixed.vertical,
        },
        margins = 4,
        widget  = wibox.container.margin
    }

    return awful.popup {
        ontop         = args.ontop or true,
        visible       = args.visible or false,
        shape         = args.shape or gears.shape.infobubble or gears.shape.rounded_rect,
        border_width  = args.border_width or 10,
        border_color  = args.border_color or beautiful.bg_normal,
        maximum_width = args.maximum_width or 300,
        --offset        = args.offset or { y = 5 },

        widget        = widget,

        --preferred_anchors = "middle",
        --border_color      = beautiful.border_color,
        --border_width      = beautiful.border_width,
    }
end

function popup:append(widget)
    --popup_list.append(widget)
end

function popup:update(widget)
    popup_list.append(widget)
end

return setmetatable(popup, { __call = function(_, ...)
    return popup:init(...)
end })