local awful      = require("awful")
local gears      = require("gears")
local key        = capi.wmapi.event.key
local mouse      = capi.wmapi.event.mouse

local buttonkeys = gears.table.join(
        awful.button({ }, mouse.button_click_left,
                     function(c)
                         c:emit_signal("request::activate", "mouse_click", { raise = true })
                     end),

        awful.button({ key.mod }, mouse.button_click_left,
                     function(c)
                         c:emit_signal("request::activate", "mouse_click", { raise = true })
                         awful.mouse.client.move(c)
                     end),

        awful.button({ key.mod }, mouse.button_click_left,
                     function(c)
                         c:emit_signal("request::activate", "mouse_click", { raise = true })
                         awful.mouse.client.resize(c)
                     end)
)

return buttonkeys
