local xrandr = require("modules.foggy.xrandr")

local test   = {}

function init()
    local b = capi.widget:button()
    b:set_text("Monitors")
    return b:get()
end

return setmetatable(test, { __call = function(_, ...)
    return init(...)
end })
