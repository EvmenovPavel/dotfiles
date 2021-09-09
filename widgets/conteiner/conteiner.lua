local awful     = require("awful")
local wibox     = require("wibox")

local conteiner = {}

function conteiner:init()
    local widget = wibox.widget({
        awful.widget.layoutlist {
            --source          = awful.widget.layoutlist.source.default_layouts,
            screen = 1,
            --base_layout     = wibox.widget ({
            --    spacing         = 5,
            --    forced_num_cols = 3,
            --    layout          = wibox.layout.grid.vertical,
            --}),
        },
        margins = 4,
        widget  = wibox.container.margin,
    })
    --,
    --preferred_anchors = "middle",
    --border_color = beautiful.border_color,
    --border_width = beautiful.border_width,
    --shape = gears.shape.infobubble,
    --}


    return widget
end