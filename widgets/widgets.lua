local widgets = {
    systray  = require("widgets.systray"),

    keyboard = require("widgets.keyboard"),

    cpu      = require("widgets.cpu"),

    memory   = require("widgets.memory"),

    clock    = require("widgets.calendar"),

    volume   = require("widgets.volume"),

    tasklist = require("widgets.tasklist"),

    taglist  = require("widgets.taglist"),

    reboot   = require("widgets.reboot"),

    pacmd    = require("widgets.pacmd"),

    sensors    = require("widgets.sensors"),

    --spotify  = require("widgets.spotify"),

    pad      = require("widgets.pad")

    --require("widgets.bluetooth"),
    --require("widgets.wifi"),
    --require("widgets.battery"),
    --require("widgets.layout-box"),

    --checkbox      = require("widgets.checkbox"),
    --notifications = require("widgets.notifications"),
}

return widgets
