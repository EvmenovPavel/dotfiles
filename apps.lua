local apps            = {}

apps.default          = {
    terminal    = "kitty",
    launcher    = "rofi -modi run -show drun",
    lock        = "i3lock",
    filebrowser = "nautilus" or "nemo",
    gxkb        = "gxkb",
    nm          = "nm-applet",
    blueman     = "blueman-applet",
    flameshot   = "flameshot",
}

return apps
