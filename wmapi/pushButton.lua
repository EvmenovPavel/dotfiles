local wibox     = require("lib.wibox")
local beautiful = require("lib.beautiful")

local wmapi     = {}

function wmapi()
    wmapi.pushButton  = {}
    pushButton.widget = wibox.widget {}

    function wmapi.pushButton:create(name)
        -- config widget

        local obj   = {}
        obj.name    = name
        obj.enabled = true

        obj.size    = {
            height = 24,
            width  = 88,
        }

        obj.font    = {
            family = "Monospace",
            size   = 10,
        }

        -- cursor = "Arrow",

        obj.icon    = {
            path   = beautiful.awesome_icon,
            height = 16,
            width  = 16,
        }

        obj.markup  = "pushButton"

        obj.color   = {
            --bg     = colorHide,
            --widget = wibox.container.background,
        }

        function obj:test()
            print("Hello " .. obj.name)
        end

        --setmetatable(obj,
        --             self)
        --self.__index = self
        return obj
    end

    pushButton.widget:connect_signal("button::release",
                                     function(...)
                                     end)
    -- скорее всего, button::press не нужен будет
    pushButton.widget:connect_signal("button::press",
                                     function(...)
                                     end)

    return wmapi
end