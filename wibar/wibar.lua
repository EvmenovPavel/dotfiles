local beautiful = require("beautiful")
local awful     = require("awful")
local wibox     = require("wibox")
local widgets   = require("widgets")

local foggy     = require('foggy')

local mywibar   = {}

function mywibar:w_left(s)
    return {
        require("modules.taglist")(s),
        layout = wibox.layout.fixed.horizontal
    }
end

function mywibar:w_middle(s)
    return {
        require("modules.tasklist")(s),
        layout = wibox.layout.fixed.horizontal
    }
end

function mywibar:w_right(s)
    if wmapi:is_screen_primary(s) then
        local scrnicon = wibox.widget.background(wibox.widget.imagebox(resources.awesome), '#313131')
        scrnicon:buttons(awful.util.table.join(
                awful.button({ }, event.mouse.button_click_left, function(c)
                    foggy.menu()
                end)
        ))

        return {
            widgets.reboot(),

            widgets.systray(s),
            --widgets.keyboard(),

            widgets.volume(),
            widgets.brightness(),
            --widgets.battery(),
            widgets.calendar(),

            --scrnicon,

            layout = wibox.layout.fixed.horizontal
        }

    end

    return {
        layout = wibox.layout.fixed.horizontal
    }
end

local function init(s)
    local wibar = awful.wibar({
        --bg           = beautiful.bg_normal .. "55",

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

    --local function mouse_move()
    --    local id_screen = wmapi:screen_id(capi.mouse.screen)
    --    local coords    = wmapi:mouse_coords()
    --    local geometry  = wibar:geometry()
    --
    --    local SIZE      = {
    --        x = -1,
    --        y = 5
    --    }
    --
    --    local x         = coords.x - geometry.width * id_screen
    --
    --    if (x > SIZE.x) and (SIZE.y > coords.y) then
    --        capi.mouse.coords {
    --            x = geometry.width * id_screen + SIZE.x,
    --            y = coords.y
    --        }
    --    end
    --
    --end

    --wibar:connect_signal("mouse::move", mouse_move)
    --wmapi:update(mouse_move, 0.01)

    return mywibar
end

return setmetatable(mywibar, { __call = function(_, ...)
    return init(...)
end })
