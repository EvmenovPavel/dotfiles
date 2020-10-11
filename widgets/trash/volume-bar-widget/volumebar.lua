local gears  = require("lib.gears")
local lain   = require("lain")
--local pulse = require("lain.widget.pulse")
local awful  = require("lib.awful")
local wibox  = require("lib.wibox")

local markup = lain.util.markup

return function(theme)
    -- ALSA volume bar
    local volume  = {}

    volume.icon   = wibox.widget.imagebox(theme.widget_vol)
    theme.volume  = lain.widget.alsa({
                                         settings = function()
                                             local vol

                                             local hide     = markup.fontfg(theme.font, theme.bg_normal, "0")
                                             local show     = markup.fontfg(theme.font, theme.widget.volume_font, "0")
                                             local symbol   = markup.fontfg(theme.font, theme.widget.volume_font, "% ")

                                             local proc     = tonumber(volume_now.level)

                                             local vol_text = markup.fontfg(theme.font, theme.widget.volume_font, proc)

                                             if volume_now.status == "off" or proc == 0 then
                                                 vol = show .. symbol .. hide .. hide
                                             elseif proc == 100 then
                                                 vol = vol_text .. symbol
                                             elseif proc < 10 then
                                                 vol = vol_text .. symbol .. hide .. hide
                                             else
                                                 vol = vol_text .. symbol .. hide
                                             end

                                             widget:set_markup(vol)
                                         end
                                     })

    volume.widget = theme.volume.widget

    return volume
end
