local wibox     = require("lib.wibox")
local beautiful = require("lib.beautiful")

local wmapi     = require("wmapi")
local markup    = wmapi.markup
local resources = require("resources")
local config    = require("config")

return function()
    local icon   = wmapi:imagebox(resources.widgets.user)

    local uname  = io.popen("getent passwd $USER | cut -d ':' -f 5 | cut -d ',' -f 1"):read()
    local widget = wmapi:textbox(markup.font(config.font, markup.fg.color(beautiful.colors.widget.fg_widget, uname)))

    local user   = wibox.widget {
        icon,
        widget,
        widget = wibox.layout.fixed.horizontal,
    }

    return user
end
