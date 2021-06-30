local programm        = {}

programm.rofi         = "rofi -modi run -show drun"
programm.manager      = "kitty mc" or "nemo"
programm.terminal     = "x-terminal-emulator"
programm.htop         = programm.terminal .. " htop"
programm.editor       = "vim" or "nano"
programm.browser      = "x-www-browser"
programm.screenshot   = "flameshot gui"
programm.lockscreen   = "i3lock-fancy"
programm.pavucontrol  = "pavucontrol"
programm.lxappearance = "lxappearance"
programm.printer      = "system-config-printer"

return programm
