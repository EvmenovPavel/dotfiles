local beautiful = require("beautiful")
local awful     = require("awful")
local wibox     = require("wibox")
local widgets   = require("widgets")

local mywibar   = {}

function mywibar:w_left(s)
    return {
        widgets.taglist(s),
        layout = wibox.layout.fixed.horizontal
    }
end

function mywibar:w_middle(s)
    return {
        widgets.tasklist(s),
        layout = wibox.layout.fixed.horizontal
    }
end

function screen_if_test(s)
    local w    = capi.widget.button()

    local s_id = capi.wmapi:screen_id(s)

    w:set_text("Screen: " .. tostring(s_id))
    w:set_key(capi.event.mouse.button_click_left)

    return w:get()
end

function mywibar:w_right(s)
    if capi.wmapi:is_screen_primary(s) then
        return {
            widgets.systray(s),
            widgets.keyboard(),

            widgets.volume(),
            widgets.brightness(),
            --widgets.pacmd(),
            --widgets.cpu(),
            --widgets.battery(),
            --widgets.memory(),
            --widgets.clock(),
            widgets.calendar(),

            widgets.reboot(),
            widgets.xrandr(),

            screen_if_test(s),

            layout = wibox.layout.fixed.horizontal
        }
    end

    return {
        screen_if_test(s),

        layout = wibox.layout.fixed.horizontal
    }
end

local function init(s)
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
        mywibar:w_left(s),
        mywibar:w_middle(s),
        mywibar:w_right(s),
        layout = wibox.layout.align.horizontal,
    }

    local function mouse_move()
        local id_screen = capi.wmapi:screen_id(capi.mouse.screen)
        local coords    = capi.wmapi:mouse_coords()
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

return setmetatable(mywibar, { __call = function(_, ...)
    return init(...)
end })
