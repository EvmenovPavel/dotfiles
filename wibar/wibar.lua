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
    if capi.wmapi:screen_primary(s) then
        return {
            widgets.systray(s),
            widgets.keyboard(),

            widgets.volume(),
            widgets.brightness(),
            --widgets.pacmd(),
            widgets.cpu(),
            widgets.battery(),
            widgets.memory(),
            widgets.clock(),
            widgets.reboot(),
            widgets.test(),
            --widgets.spotify(s),

            layout = wibox.layout.fixed.horizontal
        }
    end

    return {
        layout = wibox.layout.fixed.horizontal
    }
end

local naughty = require("naughty")

function test(text)
    naughty:message({
                        icon  = "battery.svg",
                        title = text,
                        text  = text
                    })
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
                                  height       = beautiful.wr_height,
                                  screen       = s,
                              })

    wibar:setup {
        self:w_left(s),
        self:w_middle(s),
        self:w_right(s),
        layout = wibox.layout.align.horizontal,
    }

    local function mouse_move()
        local id_screen = capi.wmapi:screen_index(capi.mouse.screen)
        local coords    = capi.wmapi:mouseCoords()
        local geometry  = wibar:geometry()

        local SIZE      = {
            x = -1,
            y = 5
        }

        local x         = coords.x - geometry.width * id_screen

        if (x > SIZE.x) and (SIZE.y > coords.y) then
            capi.mouse.coords {
                x = geometry.width * id_screen + SIZE.x,
                y = coords.y
            }
        end

    end

    --wibar:connect_signal("mouse::move", mouse_move)
    --capi.wmapi:update(mouse_move, 0.01)

    return mywibar
end

return setmetatable(mywibar, {
    __call = mywibar.create,
})
