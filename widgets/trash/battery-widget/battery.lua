-- Battery

return function()

    local battery      = {}

    battery.bat_icon   = wibox.widget.imagebox(theme.widget_battery)
    battery.bat        = lain.widget.bat({
                                             battery  = "BAT0",
                                             timeout  = 1,
                                             notify   = "on",
                                             n_perc   = { 5, 15 },
                                             settings = function()
                                                 bat_notification_low_preset      = {
                                                     title   = "Battery low",
                                                     text    = "Plug the cable!",
                                                     timeout = 15,
                                                     fg      = "#232323",
                                                     bg      = "#ffbf00"
                                                 }
                                                 bat_notification_critical_preset = {
                                                     title   = "Battery exhausted",
                                                     text    = "Shutdown imminent",
                                                     timeout = 15,
                                                     fg      = "#232323",
                                                     bg      = "#e35d6a"
                                                 }

                                                 if bat_now.status ~= "N/A" then
                                                     if bat_now.status == "Charging" then
                                                         widget:set_markup(markup.font(theme.font,
                                                                                       markup.fg.color("#232323", " +" .. bat_now.perc .. "% [" .. bat_now.watt .. "W][" .. bat_now.time .. "]")))
                                                         bat_icon:set_image(theme.widget_ac)
                                                     elseif bat_now.status == "Full" then
                                                         --theme.batcolor = "#428bca"
                                                         widget:set_markup(markup.font(theme.font,
                                                                                       markup.fg.color("#232323", " ~" .. bat_now.perc .. "% [" .. bat_now.watt .. "W][" .. bat_now.time .. "]")))
                                                         bat_icon:set_image(theme.widget_battery)
                                                     elseif tonumber(bat_now.perc) <= 35 then
                                                         --theme.batcolor = "#e35d6a"
                                                         bat_icon:set_image(theme.widget_battery_empty)
                                                         widget:set_markup(markup.font(theme.font,
                                                                                       markup.fg.color("#232323", " -" .. bat_now.perc .. "% [" .. bat_now.watt .. "W][" .. bat_now.time .. "]")))
                                                     elseif tonumber(bat_now.perc) <= 60 then
                                                         --theme.batcolor = "#e35d6a"
                                                         bat_icon:set_image(theme.widget_battery_low)
                                                         widget:set_markup(markup.font(theme.font,
                                                                                       markup.fg.color("#232323", " -" .. bat_now.perc .. "% [" .. bat_now.watt .. "W][" .. bat_now.time .. "]")))

                                                     elseif tonumber(bat_now.perc) <= 80 then
                                                         --theme.batcolor = "#ffbf00"
                                                         bat_icon:set_image(theme.widget_battery_medium)
                                                         widget:set_markup(markup.font(theme.font,
                                                                                       markup.fg.color("#232323", " -" .. bat_now.perc .. "% [" .. bat_now.watt .. "W][" .. bat_now.time .. "]")))
                                                     elseif tonumber(bat_now.perc) <= 99 then
                                                         --theme.batcolor = "#ffbf00"
                                                         bat_icon:set_image(theme.widget_battery)
                                                         widget:set_markup(markup.font(theme.font,
                                                                                       markup.fg.color("#232323", " -" .. bat_now.perc .. "% [" .. bat_now.watt .. "W][" .. bat_now.time .. "]")))
                                                     else
                                                         --theme.batcolor = "#5cb85c"
                                                         bat_icon:set_image(theme.widget_battery)
                                                         widget:set_markup(markup.font(theme.font,
                                                                                       markup.fg.color("#232323", " -" .. bat_now.perc .. "% [" .. bat_now.watt .. "W][" .. bat_now.time .. "]")))
                                                     end
                                                 else
                                                     --theme.batcolor = "#e35d6a"
                                                     widget:set_markup(markup.font(theme.font, markup.fg.color("#232323", " AC ")))
                                                     bat_icon:set_image(theme.widget_battery_no)
                                                 end
                                             end
                                         })

    battery.batbar     = wibox.widget {
        forced_height    = 1,
        forced_width     = 45,
        color            = "#232323",
        background_color = "#232323",
        margins          = 1,
        paddings         = 1,
        ticks            = true,
        ticks_size       = 5,
        widget           = wibox.widget.progressbar,
    }

    battery.batupd     = lain.widget.bat({
                                             battery  = "BAT0",
                                             timeout  = 1,
                                             settings = function()
                                                 if bat_now.status ~= "N/A" then
                                                     if bat_now.status == "Charging" then
                                                         batbar:set_color("#428bca")
                                                     elseif bat_now.status == "Full" then
                                                         batbar:set_color("#777ace")
                                                     elseif tonumber(bat_now.perc) <= 35 then
                                                         batbar:set_color("#e35d6a")
                                                     elseif tonumber(bat_now.perc) <= 80 then
                                                         batbar:set_color("#ffbf00")
                                                     elseif tonumber(bat_now.perc) <= 99 then
                                                         batbar:set_color("#5cb85c")
                                                     else
                                                         batbar:set_color("#5cb85c")
                                                     end
                                                     batbar:set_value(bat_now.perc / 100)
                                                 else
                                                     return
                                                 end
                                             end
                                         })

    battery.batbg      = wibox.container.background(batbar, "#474747", gears.shape.rectangle)
    battery.bat_widget = wibox.container.margin(batbg, 2, 7, 4, 4)

    return battery
end