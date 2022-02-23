local beautiful      = require("beautiful")

local RulesMaximized = {}

function init()
    return {
        rule_any   = {
            class = {
                "kitty",
                "TeamViewer"
            },
        },
        properties = {
            maximized    = true,
            border_width = beautiful.border_width,
            callback     = function(c)
                c.border_width = 0
                --awful.client.movetoscreen(c, client.focus.screen)
            end
        }
    }
end

return setmetatable(RulesMaximized, { __call = function(_, ...)
    return init(...)
end })