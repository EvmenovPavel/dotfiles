local awful      = require("awful")
local gears      = require("gears")
local key        = require("event").key
local mouse      = require("event").mouse

local buttonkeys = gears.table.join(
        awful.button({ }, mouse.button_click_left,
                     function(c)
                         if c ~= nil then
                             c:emit_signal("request::activate", "mouse_click", {
                                 raise = true
                             })
                         end
                     end),

        awful.button({ key.win }, mouse.button_click_left,
                     function(c)
                         if c ~= nil then
                             c:emit_signal("request::activate", "mouse_click", {
                                 raise = true
                             })
                             awful.mouse.client.move(c)
                         end
                     end),

        awful.button({ key.win }, mouse.button_click_right,
                     function(c)
                         if c ~= nil then
                             c:emit_signal("request::activate", "mouse_click", {
                                 raise = true
                             })
                             awful.mouse.client.resize(c)
                         end
                     end)

)

return buttonkeys
