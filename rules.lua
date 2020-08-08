local awful         = require("awful")
local beautiful     = require("beautiful")

-- define screen height and width
local screen_height = awful.screen.focused().geometry.height
local screen_width  = awful.screen.focused().geometry.width

-- define module table
local rules         = {}

-- return a table of client rules including provided keys / buttons
function rules:create(clientkeys, buttonkeys)
    return {
        {
            rule_any   = {
                type = {
                    "normal",
                    "dialog"
                }
            },
            properties = {
                titlebars_enabled = true,
                border_width      = 0,
                border_color      = "#ff0000",

                maximized         = false,
                fullscreen        = false,
                --maximized_vertical = true,
                --maximized_horizontal = true,

                focus             = awful.client.focus.filter,
                raise             = true,

                keys              = clientkeys,
                buttons           = buttonkeys,

                --size_hints_honor  = true,
                --honor_workarea    = true,
                --honor_padding     = true,

                screen            = awful.screen.preferred,

                --placement         = awful.placement.centered,
                placement         = awful.placement.no_overlap + awful.placement.no_offscreen,

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
            }
        },

    },

    {
        rule       = {
            class = "Navigator"
        },
        except     = {
            icon_name = "Picture-in-Picture"
        },
        properties = {
            maximized = true,
        }
    }
end

return rules
