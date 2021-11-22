local wibox     = require("wibox")
local dpi       = require("beautiful").xresources.apply_dpi
local resources = require("resources")

--local mouse     = capi.event.mouse

local test      = {}
local foggy     = require("foggy")

function test:init()
    local b = capi.widget:button()

    local w = capi.widget:textbox("test")

    --b:set_func(
    --        function()
    --        end
    --)

    --capi.wmapi:update(function()
    --    local monitors = foggy.build_menu_count()
    --    w:set_text()
    --end, 1)

    --capi.log:message(tostring(mouse.screen.index))

    b:set_func(
            function()
                local monitors = foggy.menu()
                b:set_text(tostring(#monitors))

                --foggy.menu()
            end
    )

    return b:get()
end

return setmetatable(test, { __call = function(_, ...)
    return test:init(...)
end })
