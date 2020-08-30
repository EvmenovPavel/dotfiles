local awful            = require("awful")

-- define screen height and width
local screen_height    = awful.screen.focused().geometry.height
local screen_width     = awful.screen.focused().geometry.width

-- define module table
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

local Calc             = {
    rule       = {
        class = "Gnome-calculator",
    },
    properties = {
        titlebars_enabled = true,
        floating          = true,

        width             = 360,
        height            = 400,
    },
}

-- return a table of client rules including provided keys / buttons
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
                border_width      = 1,
                --border_color      = "#ff0000",

                --maximized         = false,
                --fullscreen        = false,

                focus             = awful.client.focus.filter,
                raise             = true,

                keys              = clientkeys,
                buttons           = buttonkeys,

                size_hints_honor  = true,
                honor_workarea    = true,
                honor_padding     = true,

                screen            = awful.screen.preferred,

                placement         = awful.placement.centered,
                --placement         = awful.placement.no_overlap + awful.placement.no_offscreen,

                --callback          = function(c)
                --    local workarea = awful.screen.focused().workarea
                --
                --    c:geometry({
                --                   x      = 0,
                --                   -- FIX
                --                   -- сюда надо передавать размер wibar
                --                   -- что бы вниз не отпускало некоторые апп
                --                   --
                --                   -- Либо, делать апп не фулл
                --                   y      = 27,
                --                   width  = workarea.width,
                --                   height = workarea.height
                --               })
                --end
            },
        },

        -- Firefox
        PictureInPicture,

        -- Calculator
        Calc,
    }

    return list_rules
end

return setmetatable(rules, { __call = function(_, ...)
    return rules:init(...)
end })