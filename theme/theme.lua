local theme           = {}

theme.focus           = false
theme.shape           = false
theme.borderWidth     = true

theme.font_size       = 9
theme.font            = "SF Pro Text " .. tostring(theme.font_size)
theme.title_font_size = 20
theme.title_font      = "SF Pro Display Medium " .. tostring(theme.title_font_size)

theme.wallpapers      = capi.path .. "/wallpapers"

theme.datetime        = "%A %d %B  %H:%M:%S"

theme.position        = {
    center = "center",
    top    = "top",
    left   = "left",
    button = "bottom",
    right  = "right",
}

require("theme.titlebar")(theme)
require("theme.taglist")(theme)
require("theme.tasklist")(theme)
require("theme.menu")(theme)


-- ### Background ### --
theme.bg_normal            = "#1f2430"
theme.bg_dark              = "#000000"
theme.bg_focus             = "#151821"
theme.bg_urgent            = "#ed8274"
theme.bg_minimize          = "#444444"


-- ### systray ### --
theme.systray_icon_spacing = 2
theme.bg_systray           = theme.bg_normal


-- ### Foreground ### --
theme.fg_normal            = "#ffffff"
theme.fg_focus             = "#e4e4e4"
theme.fg_urgent            = "#ffffff"
theme.fg_minimize          = "#ffffff"


-- ### Window Borders ### --
theme.border_radius        = 10
theme.useless_gap          = 10
theme.gap_single_client    = true

theme.border_width         = 10
theme.border_normal        = theme.bg_normal
theme.border_focus         = "#ff8a65"
theme.border_marked        = theme.fg_urgent

return theme
