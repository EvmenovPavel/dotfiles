local awful            = require("lib.awful")

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

                focus             = awful.client.focus.filter,
                raise             = true,

                keys              = clientkeys,
                buttons           = buttonkeys,

                size_hints_honor  = true,
                honor_workarea    = true,
                honor_padding     = true,

                screen            = awful.screen.preferred,

                placement         = awful.placement.centered,

                callback          = function(c)
                    local screen_width  = awful.screen.focused().geometry.width
                    local screen_height = awful.screen.focused().geometry.height

                    --local workarea = awful.screen.focused().workarea

                    local width         = c.width
                    local height        = c.height

                    if width < 800 and height < 800 then
                        c.floating  = true

                        c:geometry({
                                       x = screen_width / 2 - width / 2,
                                       y = screen_height / 2 - height / 2,
                                   })

                    else
                        c.floating  = false
                    end
                end
            },
        },

        -- Firefox
        PictureInPicture,
    }

    return list_rules
end

return setmetatable(rules, { __call = function(_, ...)
    return rules:init(...)
end })