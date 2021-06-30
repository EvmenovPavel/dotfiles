local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local dpi       = require("beautiful").xresources.apply_dpi
local resources = require("resources")

local test = {}

function test:init()
    local rebootWidget = wibox.widget {
        {
            id     = "icon",
            image  = resources.path .. "/test.png",
            widget = wibox.widget.imagebox,
            resize = true
        },
        layout = wibox.layout.fixed.horizontal
    }

    rebootWidget:buttons(
            gears.table.join(
                    awful.button({}, 1, nil,
                                 function()

                                     print(capi.mouse.coords().x)
                                     -- Change the position
                                     capi.mouse.coords {
                                         x = 185,
                                         y = 10
                                     }

                                     --capi.awesome.restart()
                                 end
                    )
            )
    )

    local container = capi.wmapi:container(wibox.container.margin(rebootWidget, dpi(7), dpi(7), dpi(7), dpi(7)))

    return container
end

return setmetatable(test, {
    __call = test.init
})