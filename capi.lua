-- Global --

capi = {
    primary = 2,
    root    = root,
    screen  = screen,
    tag     = tag,
    dbus    = dbus,
    button  = button,
    client  = client,
    awesome = awesome,
    mouse   = mouse,
    timer   = timer,
    unpack  = unpack,

    home    = os.getenv("HOME"),
    path    = os.getenv("HOME") .. "/.config/awesome",

    wmapi   = require("wmapi"),
    log     = require("logger"),
}

return capi