local awful         = require("awful")
local wibox         = require("wibox")
local gears         = require("gears")
local dpi           = require("beautiful").xresources.apply_dpi

local PATH_TO_ICONS = os.getenv("HOME") .. "/.config/awesome/icons/"

local restart = {}

function restart:init()
    local rebootWidget        = wibox.widget {
        {
            id     = "icon",
            image  = PATH_TO_ICONS .. "restart-alert.svg",
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