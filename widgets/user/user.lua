local wibox = require("wibox")

return function()
    local icon = wmapi.widget:imagebox()
    icon:set_image(resources.widgets.user)

    local uname  = io.popen("getent passwd $USER | cut -d ':' -f 5 | cut -d ',' -f 1"):read()
    local widget = wmapi.widget:textbox()
    widget:set_text(uname)

    local user = wibox.widget({
        icon,
        widget,
        widget = wibox.layout.fixed.horizontal,
    })

    return user
end
