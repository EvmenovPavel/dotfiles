local gears = require("gears")

local theme = {}

function theme:init(config)
    config.focus                        = false

    config.font_size                    = 10
    config.font                         = "SF Pro Text " .. tostring(config.font_size)
    config.title_font_size              = 20
    config.title_font                   = "SF Pro Display Medium " .. tostring(config.title_font_size)

    config.datetime                     = "%A %d %B  %H:%M:%S"

    -- ### Background ### --
    config.bg_normal                    = color.active_inner -- "#1f2430"
    config.bg_dark                      = "#ffffff11"
    config.bg_focus                     = color.active -- "#5A5A5A"
    config.bg_urgent                    = "#ed8274"
    config.bg_minimize                  = "#444444"


    -- ### systray ### --
    config.mouse_enter                  = "#ffffff11"
    config.mouse_leave                  = "#ffffff00"
    config.button_press                 = "#ffffff22"
    config.button_release               = "#ffffff11"

    -- ### systray ### --
    config.systray_icon_spacing         = 2
    config.bg_systray                   = config.bg_normal


    -- ### Foreground ### --
    config.fg_normal                    = "#000000"
    config.fg_focus                     = "#e4e4e4"
    config.fg_urgent                    = "#ffffff"
    config.fg_minimize                  = "#ffffff"

    config.active_inner_color           = "#000000"
    config.border_color                 = "#BBC1E1"
    config.border_hover_color           = "#275EFE"


    -- ### Window Borders ### --
    config.border_radius                = 10
    config.useless_gap                  = 10
    config.gap_single_client            = true

    config.border_width                 = 4
    config.border_normal                = config.bg_normal
    config.border_focus                 = "#ff8a65"
    config.border_marked                = config.fg_urgent

    config.shape_rounded_rect           = 10
    --theme.opacity                  = 0.5

    -- Affects mostly the taglist and tasklist..
    --theme.fg_urgent                = "#ffffff"
    --theme.bg_urgent                = "#ff0000"

    -- Set the client border to be orange and large.
    --theme.border_color_urgent      = "#ffaa00"
    --theme.border_width_urgent      = 6

    -- Set the titlebar green.
    --theme.titlebar_bg_urgent       = "#00ff00"
    --theme.titlebar_fg_urgent       = "#000000"

    config.shape_border_width_enter     = 1
    config.shape_border_width_leave     = 1

    local btnCloseColor                 = gears.surface.load_from_shape(20, 20, gears.shape.circle, "#D12D2D")
    config.titlebar_close_button_normal = btnCloseColor
end

return theme
