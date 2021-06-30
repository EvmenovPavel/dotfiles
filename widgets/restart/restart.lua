local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local dpi       = require("beautiful").xresources.apply_dpi
local resources = require("resources")

local restart   = {}

function restart:init()
    local rebootWidget = wibox.widget {
        {
            id     = "icon",
            image  = resources.path .. "/restart-alert.svg",
            widget = wibox.widget.imagebox,
            resize = true
        },
        layout = wibox.layout.fixed.horizontal
    }

    rebootWidget:buttons(
            gears.table.join(
                    awful.button({}, 1, nil,
                                 function()
                                     capi.awesome.restart()
                                 end
                    )
            )
    )

    local container = capi.wmapi:container(wibox.container.margin(rebootWidget, dpi(7), dpi(7), dpi(7), dpi(7)))

    return container
end

return setmetatable(restart, {
    __call = restart.init
})