local awful     = require("lib.awful")
local beautiful = require("lib.beautiful")
local wibox     = require("lib.wibox")

local widgets   = {
    systray       = wibox.layout.margin(require("widgets.systray"), 3, 3, 3, 3),

    keyboard      = awful.widget.keyboardlayout(),

    cpu           = require("widgets.cpu-widget"),
    calendar      = require("widgets.calendar"),

    volume        = require("widgets.volume-widget.volume"),

    tasklist      = require("widgets.tasklist"),
    taglist       = require("widgets.taglist"),

    --require("widgets.bluetooth"),
    --require("widgets.wifi"),
    --require("widgets.battery"),
    --require("widgets.layout-box"),

    --require("widgets.reboot"),
    --require("widgets.checkbox"),
    notifications = require("widgets.notifications"),
}

return widgets