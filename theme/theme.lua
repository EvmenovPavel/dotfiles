local xresources                                      = require("lib.beautiful.xresources")
local dpi                                             = xresources.apply_dpi

local theme                                           = {}


-- Font
theme.font                                            = "SF Pro Text 9"
theme.title_font                                      = "SF Pro Display Medium 10"


require("theme.titlebar")(theme)
require("theme.taglist")(theme)
require("theme.tasklist")(theme)
require("theme.menu")(theme)


-- Background
theme.bg_normal                                       = "#1f2430"
theme.bg_dark                                         = "#000000"
theme.bg_focus                                        = "#151821"
theme.bg_urgent                                       = "#ed8274"
theme.bg_minimize                                     = "#444444"
theme.bg_systray                                      = theme.bg_normal

-- Foreground
theme.fg_normal                                       = "#ffffff"
theme.fg_focus                                        = "#e4e4e4"
theme.fg_urgent                                       = "#ffffff"
theme.fg_minimize                                     = "#ffffff"

-- Window Gap Distance
theme.useless_gap                                     = dpi(7)

-- Show Gaps if Only One Client is Visible
theme.gap_single_client                               = true

-- Window Borders
theme.border_width                                    = dpi(0)
theme.border_normal                                   = theme.bg_normal
theme.border_focus                                    = "#ff8a65"
theme.border_marked                                   = theme.fg_urgent

return theme
