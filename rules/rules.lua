local awful     = require("awful")
local beautiful = require("beautiful")

local rules     = {}

function rules:init(clientkeys, buttonkeys)
    return {
        rule_any   = {
            type = {
                "normal",
                "dialog"
            }
        },
        properties = {
            titlebars_enabled = beautiful.titlebars_enabled,

            border_width      = beautiful.border_width,
            border_color      = beautiful.border_normal,

            focus             = awful.client.focus.filter,

            raise             = true,

            keys              = clientkeys,
            buttons           = buttonkeys,

            screen            = awful.screen.preferred,
            placement         = awful.placement.no_overlap + awful.placement.no_offscreen,

            callback          = function(c)

                --local client = c

                --capi.wmapi:client_info(client)


                --c:deny("autofocus", "mouse_enter")
                --awful.client.setslave(c)
                --apply_delayed_rule(c)
                --end

                --callback          = function(c)
                --    c.border_width = 0
                --
                --    --awful.client.movetoscreen(c, mouse.screen)
                --
                --    --local screen   = c.screen
                --    --local workarea = screen.geometry
                --    --local index    = screen.index
                --
                --    --local workarea = awful.screen.focused().workarea
                --    --local y        = workarea.height + workarea.y - c:geometry().height - beautiful.useless_gap * 2 - beautiful.border_width * 2
                --    --local x        = workarea.width + workarea.x - c:geometry().width - beautiful.useless_gap * 2 - beautiful.border_width * 2
                --
                --    --c.y = c.screen.geometry.y + c.screen.geometry.height* 0.04
                --
                --    local width    = c.width
                --    --capi.log:message(width)
                --    local height   = c.height
                --    --capi.log:message(height)
                --
                --    if width < 1820 and height < 980 then
                --    --if width < capi.wmapi:getScreenWidth() and height < capi.wmapi:getScreenHeight() - beautiful.wr_height then
                --        c.floating = true
                --
                --        --awful.client.movetoscreen(c, client.focus.screen)
                --
                --        -- окно переносит, где находиться мышка (координаты)
                --        c:geometry({
                --                       --x = 30,
                --                       --y = 30,
                --                       --x = x,
                --                       --y = y,
                --                       --x = (index * workarea.width) / 2 - width / 2,
                --                       --y = workarea.height / 2 - height / 2
                --                   })
                --
                --        --local g    = c:geometry()
                --        --g.x        = g.x - x
                --        --g.y        = g.y - y
                --        --c:geometry(g)
                --
                --        --elseif workarea.height < height or workarea.width < width then
                --        --    c.maximized = true
                --        --    capi.log:message("c.maximized = true")
                --    else
                --        c.floating  = false
                --        --c.maximized = true
                --    end
            end
        }
    }
end

return setmetatable(rules, { __call = function(_, ...)
    return rules:init(...)
end })