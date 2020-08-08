local programm      = {}

-- pavucontrol
-- lxappearance
-- nm-applet
-- system-config-printer

programm.run        = "rofi -modi run -show drun"
programm.manager    = "kitty mc" or "nemo"
programm.terminal   = "x-terminal-emulator"
programm.editor     = os.getenv("EDITOR") or "nano"
programm.browser    = "x-www-browser"
programm.screenshot = "flameshot gui"
programm.lockscreen = "i3lock-fancy"

return programm
