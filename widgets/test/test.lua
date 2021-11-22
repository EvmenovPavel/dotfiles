local foggy     = require("foggy")

local test      = {}

function test:init()
    local b = capi.widget:button()
    b:set_text("Monitors")

    b:set_func(
            function()
                foggy.menu()
                --local monitors = foggy.menu()
                --b:set_text(tostring(#monitors))
            end
    )

    return b:get()
end

return setmetatable(test, { __call = function(_, ...)
    return test:init(...)
end })
