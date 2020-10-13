local beautiful = require("beautiful")
local awful     = require("awful")
local wibox     = require("wibox")
local widgets   = require("widgets")

local mywibar   = {}

function mywibar:w_left(s)
    return {
        widgets.taglist:create(s),
        layout = wibox.layout.fixed.horizontal
    }
end

function mywibar:w_middle(s)
    return {
        widgets.tasklist:create(s),
        layout = wibox.layout.fixed.horizontal
    }
end

function mywibar:w_right(s)
    --if capi.wmapi:display_primary(s) then
    if capi.wmapi:display_primary(s) then
        return {
            --widgets.brightness(),
            widgets.systray(s),
            widgets.keyboard(),
            widgets.volume(s),
            widgets.cpu(),
            widgets.clock,
            widgets.reboot,
            --widgets.spotify(s),

            layout = wibox.layout.fixed.horizontal
        }
    end

    return {
        layout = wibox.layout.fixed.horizontal
    }
end

function mywibar:create(s)
    local wibar = awful.wibar({
                                  ontop        = false,
                                  stretch      = true,
                                  position     = beautiful.position.top,
                                  border_width = 1,
                                  border_color = beautiful.bg_dark,
                                  --bg           = "#00000099",
                                  fg           = beautiful.fg_normal,
                                  visible      = true,
                                  height       = 27,
                                  screen       = s,
                              })

    wibar:setup {
        self:w_left(s),
        self:w_middle(s),
        self:w_right(s),
        layout = wibox.layout.align.horizontal,
    }
end

return mywibar
--return setmetatable(mywibar, {
--    __call = mywibar.create,
--})
