local wibox = require("wibox")
local wmapi = require("wmapi")

return function()
    local icon   = wmapi:imagebox(resources.widgets.user)

    local uname  = io.popen("getent passwd $USER | cut -d ':' -f 5 | cut -d ',' -f 1"):read()
    local widget = wmapi:textbox(uname)

    local user   = wibox.widget {
        icon,
        widget,
        widget = wibox.layout.fixed.horizontal,
    }

    return user
end
