local foggy = require("modules.foggy.menu")

local test  = {}

function test:init()
    local b = capi.widget:button()
    b:set_text("Monitors")

    capi.wmapi:update(function()
        local monitors = foggy.build_menu_count()
        b:set_text("screens: " .. tostring(#monitors))

        --screen[2]:fake_remove()
        --screen[2]:set_auto_dpi_enabled(1)
        --local str = ">"
        --for i, it in ipairs(monitors) do
        --str = str .. tostring(it.name)
        --end

    end, 10)

    b:set_func(
            function()
                --local monitors = foggy.build_menu_count()

                --for i, c in ipairs(client.get()) do
                --    if c then
                --        if #monitors < capi.wmapi:screen_index(c.screen) then
                --            --c:move_to_tag(screen[1].tags[2])
                --
                --            -- переносит, где активное окно
                --            c:move_to_screen(screen[1])
                --        end
                --    end
                --
                --end


                screen[2]:fake_remove()

                --capi.wmapi:list_client()
            end
    )

    return b:get()
end

return setmetatable(test, { __call = function(_, ...)
    return test:init(...)
end })
