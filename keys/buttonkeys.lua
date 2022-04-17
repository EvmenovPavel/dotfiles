local awful      = require("awful")
local gears      = require("gears")

local buttonkeys = gears.table.join(
        awful.button(
                {},
                event.mouse.button_click_left,
                function(c)
                    if c then
                        c:emit_signal("request::activate", "mouse_click", { raise = true })
                    end
                end
        )
)

return buttonkeys
