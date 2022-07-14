local xrandr        = require("modules.foggy.xrandr")
local awful         = require("awful")
local notifications = require("notifications")

local test          = {}

function test:init()
    local b   = capi.widget:button()

    local fun = function()
        local clients = {}

        local tag     = awful.screen.focused().selected_tag
        if not tag then
            return
        end

        local list_clients = tag:clients()

        local str          = ""
        local _c           = client.focus

        for i, c in ipairs(list_clients) do
            if _c == c then
                notifications:message({ title = "test", text = c.name })
            else
                notifications:message({ title = "not test", text = c.name })
            end
        end
    end

    b:set_func(fun)

    b:set_text("Monitors")
    return b:get()
end

return setmetatable(test, { __call = function(_, ...)
    return test:init(...)
end })
