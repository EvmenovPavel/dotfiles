local theme           = {}

theme.focus           = false
theme.shape           = false
theme.borderWidth     = true

theme.font_size       = 10
theme.font            = "SF Pro Text " .. tostring(theme.font_size)
theme.title_font_size = 20
theme.title_font      = "SF Pro Display Medium " .. tostring(theme.title_font_size)

theme.datetime        = "%A %d %B  %H:%M:%S"

theme.position        = {
    center = "center",
    top    = "top",
    left   = "left",
    botton = "bottom",
    right  = "right",
}

require("theme.ttitlebar")(theme)
require("theme.ttaglist")(theme)
require("theme.ttasklist")(theme)
require("theme.tmenu")(theme)
require("theme.twibar")(theme)


-- ### Background ### --
theme.bg_normal                = "#1f2430"
theme.bg_dark                  = "#000000"
theme.bg_focus                 = "#151821"
theme.bg_urgent                = "#ed8274"
theme.bg_minimize              = "#444444"


-- ### systray ### --
theme.mouse_enter              = "#ffffff11"
theme.mouse_leave              = "#ffffff00"
theme.button_press             = "#ffffff22"
theme.button_release           = "#ffffff11"

-- ### systray ### --
theme.systray_icon_spacing     = 2
theme.bg_systray               = theme.bg_normal


-- ### Foreground ### --
theme.fg_normal                = "#ffffff"
theme.fg_focus                 = "#e4e4e4"
theme.fg_urgent                = "#ffffff"
theme.fg_minimize              = "#ffffff"

theme.active_inner_color       = "#ffffff"
theme.border_color             = "#BBC1E1"
theme.border_hover_color       = "#275EFE"

-- ### Window Borders ### --
theme.border_radius            = 10
theme.useless_gap              = 10
theme.gap_single_client        = true

theme.border_width             = 1
theme.border_normal            = theme.bg_normal
theme.border_focusw            = "#ff8a65"
theme.border_marked            = theme.fg_urgent

capi.color                     = {
    active         = "#275EFE",
    active_inner   = "#ffffff",
    focus          = "#becfff",
    border         = "#BBC1E1",
    border_hover   = "#275EFE",
    background     = "#ffffff";
    disabled       = "#F6F8FF";
    disabled_inner = "#E1E6F9";
}

theme.shape_border_width_enter = 1
theme.shape_border_width_leave = 0

return theme
