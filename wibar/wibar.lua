local beautiful = require("beautiful")
local awful     = require("awful")
local wibox     = require("wibox")
local widgets   = require("widgets")

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

--function screen_if_test(s)
--    local w    = widget.button()
--
--    local s_id = wmapi:screen_id(s)
--
--    w:set_text("Screen: " .. tostring(s_id))
--    w:set_key(event.mouse.button_click_left)
--
--    return w:get()
--end

-- {{{ Menu
-- Create a launcher widget and a main menu
--local myawesomemenu = {
--    { "manual", "terminal" .. " -e man awesome" },
--    { "edit config", "editor_cmd" .. " " .. awesome.conffile },
--    { "restart", awesome.restart },
--    { "quit", function()
--        awesome.quit()
--    end },
--}
--
--local menu_awesome  = { "awesome", myawesomemenu, resources.widgets.volume.on }
--local menu_terminal = { "open terminal", "terminal" }
--
--local mymainmenu    = awful.menu({
--                                     items = {
--                                         menu_awesome,
--                                         { "Debian", "debian.menu.Debian_menu.Debian" },
--                                         menu_terminal,
--                                     }
--                                 })
--
----root.buttons(gears.table.join(
----        awful.button({ }, event.mouse.button_click_right, function()
----            mymainmenu:toggle()
----        end)
----))
--
--local mylauncher    = awful.widget.launcher({ image = resources.widgets.volume.on,
--                                              menu  = mymainmenu })

function mywibar:w_right(s)
    widgets.expressvpn()

    if wmapi:is_screen_primary(s) then
        return {
            --mylauncher,

            widgets.systray(s),
            --widgets.keyboard(),
            wibox.widget.systray(),

            widgets.keyboard(),

            widgets.volume(),
            widgets.brightness(),
            --widgets.pacmd(),
            --widgets.cpu(),
            widgets.battery(),
            --widgets.memory(),
            --widgets.clock(),
            widgets.calendar(),

            widgets.reboot(),
            --widgets.loggingui(),
            --widgets.xrandr(),

            --widget:checkbox():get(),

            --screen_if_test(s),

            layout = wibox.layout.fixed.horizontal
        }

    end

    return {
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
