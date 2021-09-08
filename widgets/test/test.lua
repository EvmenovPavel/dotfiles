local wibox     = require("wibox")
local dpi       = require("beautiful").xresources.apply_dpi
local resources = require("resources")

local mouse     = capi.event.mouse

local test      = {}

function test:init()
    local widget = wibox.widget {
        {
            id     = "icon",
            image  = resources.path .. "/test.png",
            widget = wibox.widget.imagebox,
            resize = true
        },
        layout = wibox.layout.fixed.horizontal
    }

    local toggle = function()
        print(capi.mouse.coords().x)
        -- Change the position
        capi.mouse.coords {
            x = 185,
            y = 10
        }
    end

    capi.widget:button({ widget = widget, event = mouse.button_click_left, func = toggle })

    --local container = capi.wmapi:container(wibox.container.margin(widget, dpi(7), dpi(7), dpi(7), dpi(7)))

    return widget --container
end

return setmetatable(test, { __call = function(_, ...)
    return test:init(...)
end })
