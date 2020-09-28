local config       = {}

config.home        = os.getenv("HOME")
config.awesome     = config.home .. "/.config/awesome"
config.theme       = config.awesome .. "/theme"
config.icons       = config.awesome .. "/icons"

-- Enable sloppy focus
config.focus       = false
config.shape       = false
config.borderWidth = true

config.font        = "SF Pro Text 9"
config.title_font  = "SF Pro Display Medium 20"

--config.family      = "Source Sans Pro"
--config.size        = 9
--config.font        = config.family .. " " .. config.size

config.wallpapers = config.awesome .. "/wallpapers"

config.logging     = config.awesome .. "/logging.file"

config.datetime    = "%A %d %B  %H:%M:%S"

config.position    = {
    center = "center",
    top    = "top",
    left   = "left",
    down   = "down",
    right  = "right",
}

return config


