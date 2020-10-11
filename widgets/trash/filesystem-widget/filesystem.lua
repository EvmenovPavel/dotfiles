-- FS
local fs_icon = wibox.widget.imagebox(theme.widget_hdd)
theme.fs      = lain.widget.fs({
                                   notification_preset = { fg = theme.fg_normal, bg = theme.bg_normal, font = theme.font },
                                   settings            = function()
                                       local fsp = string.format(" %3.2f %s ", fs_now["/home"].free, fs_now["/home"].units)
                                       widget:set_markup(markup.font(theme.font, markup.fg.color("#232323", fsp)))
                                   end
                               })
