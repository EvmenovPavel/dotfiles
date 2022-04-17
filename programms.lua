local programm        = {}

local scripts         = require("scripts")

programm.rofi         = "rofi -modi run -show drun"
programm.manager      = "kitty mc" or "nemo"
programm.terminal     = "x-terminal-emulator"
programm.htop         = programm.terminal .. " htop"
programm.editor       = "vim" or "nano"
programm.browser      = "x-www-browser"
programm.screenshot   = "flameshot gui"
programm.lockscreen   = scripts.i3lock
programm.pavucontrol  = "pavucontrol"
programm.lxappearance = "lxappearance"
programm.printer      = "system-config-printer"

return programm
