local awful      = require("lib.awful")
local gears      = require("lib.gears")
local key        = require("keys").key
local mouse      = require("keys").mouse

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
                         c:emit_signal("request::activate", "mouse_click", {
                             raise = true
                         })
                         awful.mouse.client.move(c)
                     end),
        awful.button({ key.win }, mouse.button_click_right,
                     function(c)
                         c:emit_signal("request::activate", "mouse_click", {
                             raise = true
                         })
                         awful.mouse.client.resize(c)
                     end)

)

return buttonkeys
