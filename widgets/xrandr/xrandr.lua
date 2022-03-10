local xrandr = require("modules.foggy.xrandr")
local awful  = require("awful")

local test   = {}

function test:init()
    local b = capi.widget:button()
    b:set_text("Monitors")

    b:set_func(function()
        local s = capi.wmapi:easy_async_with_shell("zenity --file-selection")
        capi.log:message(tostring(s))

        b:set_text(s)
    end)

    return b:get()
end

return setmetatable(test, { __call = function(_, ...)
    return test:init(...)
end })
