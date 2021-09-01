local wibox     = require("wibox")
local resources = require("resources")

local mouse     = capi.wmapi.event.mouse

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

    capi.wmapi.widget.buttons({
                                  event = mouse.button_click_left,
                                  func  = function()
                                      capi.awesome.restart()
                                  end
                              })

    local container = capi.wmapi:container(wibox.container.margin(rebootWidget, 7, 7, 7, 7))

    return container
end

return setmetatable(restart, { __call = function(_, ...)
    return restart:init(...)
end })
