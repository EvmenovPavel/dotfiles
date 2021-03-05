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

--local mymainmenu = awful.menu({ items = {
--    { "open terminal", "terminal" }
--}
--                              })
--
--local mylauncher = capi.wmapi:launcher({
--                                           image = resources.path .. "/lock.png",
--                                           menu  = mymainmenu
--                                       })

function mywibar:w_right(s)
    if capi.wmapi:display_primary(s) then
        return {
            --mylauncher,
            widgets.systray(s),
            widgets.keyboard(),
            widgets.volume(s),
            --widgets.pad(),
            --widgets.pacmd(),
            widgets.cpu(),
            --widgets.pad(),
            --widgets.sensors(),
            --widgets.pad(),
            widgets.memory(),
            widgets.clock(),
            widgets.reboot(),
            --widgets.pacmd(),
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
                                  position     = beautiful.wr_position,
                                  border_width = 1,
                                  border_color = beautiful.bg_dark,
                                  --bg           = "#00000099",
                                  fg           = beautiful.fg_normal,
                                  visible      = true,
                                  height       = beautiful.wr_height or 27,
                                  screen       = s,
                              })

    wibar:setup {
        self:w_left(s),
        self:w_middle(s),
        self:w_right(s),
        layout = wibox.layout.align.horizontal,
    }

    return mywibar
end

return setmetatable(mywibar, {
    __call = mywibar.create,
})
