local foggy     = require("modules.foggy.menu")

local test      = {}

function test:init()
    local b = capi.widget:button()
    b:set_text("Monitors")

    b:set_func(
            function()
                capi.wmapi:update(function()
                    local monitors = foggy.build_menu_count()
                    b:set_text(tostring(#monitors))
                end, 3)
            end
    )

    return b:get()
end

return setmetatable(test, { __call = function(_, ...)
    return test:init(...)
end })
