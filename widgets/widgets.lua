local awful   = require("lib.awful")

local widgets = {
    systray       = require("widgets.systray"),

    keyboard      = awful.widget.keyboardlayout(),

    cpu           = require("widgets.cpu-widget"),
    calendar      = require("widgets.calendar"),

    volume        = require("widgets.volume-widget.volume"),

    tasklist      = require("widgets.tasklist"),
    taglist       = require("widgets.taglist"),

    reboot        = require("widgets.reboot"),

    --require("widgets.bluetooth"),
    --require("widgets.wifi"),
    --require("widgets.battery"),
    --require("widgets.layout-box"),

    checkbox      = require("widgets.checkbox"),
    notifications = require("widgets.notifications"),
}

return widgets