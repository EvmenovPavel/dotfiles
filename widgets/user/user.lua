local wibox = require("wibox")

return function()
    local icon   = wmapi.widget:imagebox()
    icon:image(resources.widgets.user)

    local uname  = io.popen("getent passwd $USER | cut -d ':' -f 5 | cut -d ',' -f 1"):read()
    local widget = wmapi.widget:textbox()
    widget:text(uname)

    local user   = wibox.widget {
        icon:get(),
        widget:get(),
        widget = wibox.layout.fixed.horizontal,
    }

    return user
end
