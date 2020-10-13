local awful            = require("awful")
local gears            = require("gears")
local beautiful        = require("beautiful")

local rules            = {}

-- Firefox
local PictureInPicture = {
    rule       = {
        class = "Firefox",
    },
    except     = {
        instance = "Navigator"
    },
    properties = {
        titlebars_enabled = true,
        floating          = true,

        width             = 470,
        height            = 290,
    }
}

local Terminals        = {
    rule_any   = {
        class = {
            "kitty"
        },
    },
    properties = {
        maximized    = true,
        border_width = beautiful.border_width,
        callback     = function(c)
            c.border_width = 0
        end
    }
}

function rules:init(clientkeys, buttonkeys)
    local list_rules = {
        {
            rule_any   = {
                type = {
                    "normal",
                    "dialog"
                }
            },
            properties = {
                titlebars_enabled = true,
                border_width      = beautiful.border_width,
                border_color      = beautiful.bg_dark,
                focus             = awful.client.focus.filter,
                raise             = true,
                keys              = clientkeys,
                buttons           = buttonkeys,
                screen            = awful.screen.preferred,
                placement         = awful.placement.no_overlap + awful.placement.no_offscreen,

                callback          = function(c)
                    c.border_width = 0

                    local width    = c.width
                    local height   = c.height

                    --local screen   = c.screen
                    --local workarea = screen.geometry
                    --local index    = screen.index

                    local workarea = awful.screen.focused().workarea
                    local y        = workarea.height + workarea.y - c:geometry().height - beautiful.useless_gap * 2 - beautiful.border_width * 2
                    local x        = workarea.width + workarea.x - c:geometry().width - beautiful.useless_gap * 2 - beautiful.border_width * 2

                    --c.y = c.screen.geometry.y + c.screen.geometry.height* 0.04

                    if width < 1820 and height < 980 then
                        c.floating = true
                        --c:geometry({
                        --               x = x,
                        --               y = y,
                        --x = (index * workarea.width) / 2 - width / 2,
                        --y = workarea.height / 2 - height / 2
                        --})

                        --local g    = c:geometry()
                        --g.x        = g.x - x
                        --g.y        = g.y - y
                        --c:geometry(g)

                    else
                        c.floating = false
                    end
                end,
            },
        },

        -- Firefox
        PictureInPicture,

        -- Terminals
        Terminals,
    }

    return list_rules
end

return setmetatable(rules, { __call = function(_, ...)
    return rules:init(...)
end })