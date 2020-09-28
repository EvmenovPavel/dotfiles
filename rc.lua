-- Standard awesome library
local awful     = require("lib.awful")

-- Import theme
local beautiful = require("lib.beautiful")
local theme     = require("theme")
beautiful.init(theme)

-- Import Logger
log            = require("logger")

-- Import Keybinds
local keybinds = require("keys.keybinds")
root.keys(keybinds.globalkeys)
root.buttons(keybinds.buttonkeys)

-- Import rules
awful.rules.rules = require("rules")(keybinds.clientkeys, keybinds.buttonkeys)

-- Autostart specified apps
local apps = require("autostart")
apps:start()

local mywibar   = require("components.mywibar")
local wallpaper = require("components.mywallpaper")

-- Titlebar library
require("widgets.titlebar")

awful.screen.connect_for_each_screen(
        function(s)
            wallpaper:set_wallpaper(s)

            for i, tag in pairs(theme.taglist_icons) do
                awful.tag.add(i, {
                    icon      = tag.icon,
                    icon_only = true,
                    layout    = awful.layout.suit.tile,
                    screen    = s,
                    selected  = i == 1
                })
            end

            -- Add the top manel to the screen
            mywibar:create(s)
        end)

-- remove gaps if layout is set to max
tag.connect_signal("property::layout", function(t)
    local current_layout = awful.tag.getproperty(t, "layout")
    if (current_layout == awful.layout.suit.max) then
        t.gap = 0
    else
        t.gap = beautiful.useless_gap
    end
end)


-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the window as a slave (put it at the end of others instead of setting it as master)
    if not awesome.startup then
        awful.client.setslave(c)
    end

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Autofocus a new client when previously focused one is closed
require("lib.awful.autofocus")

-- ===================================================================
-- Garbage collection (allows for lower memory consumption)
-- ===================================================================


--collectgarbage("setpause", 110)
--collectgarbage("setstepmul", 1000)


--local image = require("lib.image")

--local inner_widget = wibox.layout.fixed.vertical()
--
--inner_widget:insert(1, wibox.widget.textbox("String 1"))
--inner_widget:insert(1, wibox.widget.textbox("String 2"))
--inner_widget:insert(1, wibox.widget.textbox("String 3"))
--inner_widget:insert(1, wibox.widget.textbox("String 4"))
--inner_widget:insert(1, wibox.widget.textbox("String 5"))
--inner_widget:insert(1, wibox.widget.textbox("String 1"))
--inner_widget:insert(1, wibox.widget.textbox("String 2"))
--inner_widget:insert(1, wibox.widget.textbox("String 3"))
--inner_widget:insert(1, wibox.widget.textbox("String 4"))
--inner_widget:insert(1, wibox.widget.textbox("String 5"))
--inner_widget:insert(1, wibox.widget.textbox("String 1"))
--inner_widget:insert(1, wibox.widget.textbox("String 2"))
--inner_widget:insert(1, wibox.widget.textbox("String 3"))
--inner_widget:insert(1, wibox.widget.textbox("String 4"))
--inner_widget:insert(1, wibox.widget.textbox("String 5"))
--inner_widget:insert(1, wibox.widget.textbox("String 1"))
--inner_widget:insert(1, wibox.widget.textbox("String 2"))
--inner_widget:insert(1, wibox.widget.textbox("String 3"))
--inner_widget:insert(1, wibox.widget.textbox("String 4"))
--inner_widget:insert(1, wibox.widget.textbox("String 5"))
--inner_widget:insert(1, wibox.widget.textbox("String 1"))
--inner_widget:insert(1, wibox.widget.textbox("String 2"))
--inner_widget:insert(1, wibox.widget.textbox("String 3"))
--inner_widget:insert(1, wibox.widget.textbox("String 4"))
--inner_widget:insert(1, wibox.widget.textbox("String 5"))
--
---- отвечает за то, сколько может быть помещено в виджете
---- inner_height всегда должен увеличиваться
---- тк, информация будет всегда добавляться
--local inner_width, inner_height = 200, 200
---- No idea how to pick a good width and height for the wibox.
--local w                         = wibox {
--    x       = 200,
--    y       = 200,
--    width   = 200,
--    height  = 200,
--    visible = true
--}
--
--local own_widget                = wibox.widget.base.make_widget()
--w:set_widget(own_widget)
--local offset_x, offset_y = 0, 0
--local own_context        = {
--    screen = screen[1],
--    dpi    = 100
--} -- We have to invent something here... :-(
--
--local hierarchy
--hierarchy                = wibox.hierarchy.new(own_context, inner_widget, inner_width, inner_height,
--                                               function()
--                                                   log:message({ level = "1", message = "1 - widget::redraw_needed" })
--                                                   own_widget:emit_signal("widget::redraw_needed")
--                                               end,
--                                               function()
--                                                   hierarchy:update(own_context, inner_widget, inner_width, inner_height)
--                                                   log:message({ level = "1", message = "2 - widget::redraw_needed" })
--                                                   own_widget:emit_signal("widget::redraw_needed")
--                                               end, nil)
--
--
---- Mouse event
--own_widget:buttons(
--        gears.table.join(
--                awful.button({}, 4, nil,
--                             function()
--                                 --log:message({ level = "1", message = "some magic here to scroll up" })
--
--                                 --if offset_y >= 5 then
--                                 offset_y = offset_y - 5
--                                 --end
--                                 own_widget:emit_signal("widget::layout_changed")
--
--                                 -- some magic here to scroll up
--                             end
--                ),
--                awful.button({}, 5, nil,
--                             function()
--                                 --log:message({ level = "1", message = "some magic here to scroll down" })
--
--                                 --if offset_y <= 490 then
--                                 offset_y = offset_y + 5
--                                 --end
--                                 own_widget:emit_signal("widget::layout_changed")
--
--                                 -- some magic here to scroll down
--                             end
--                )
--        )
--)
--
--function own_widget:draw(context, cr, width, height)
--    -- This does the scrolling
--    cr:translate(offset_x, offset_y)
--
--    -- Then just draw the inner stuff directly
--    hierarchy:draw(own_context, cr)
--end
--
---- Start a timer to simulate scrolling: Once per second we move things slightly
--gears.timer.start_new(1, function()
--    --offset_x = -offset_x
--    own_widget:emit_signal("widget::redraw_needed")
--    return true
--end)
--
--function own_widget:before_draw_children(context, cr, width, height)
--    cr:rectangle(0, 0, width, height)
--    cr:clip()
--end
--
---- Finally, make input events work
--local function button_signal(name)
--    -- This function is basically copy&paste from find_widgets() in
--    -- wibox.drawable
--    local function traverse_hierarchy_tree(h, x, y, ...)
--        local m              = h:get_matrix_from_device()
--
--        -- Is (x,y) inside of this hierarchy or any child (aka the draw extents)?
--        -- If not, we can stop searching.
--        local x1, y1         = m:transform_point(x, y)
--        local x2, y2, w2, h2 = h:get_draw_extents()
--        if x1 < x2 or x1 >= x2 + w2 then
--            return
--        end
--        if y1 < y2 or y1 >= y2 + h2 then
--            return
--        end
--        -- Is (x,y) inside of this widget?
--        -- If yes, we have to emit the signal on the widget.
--        local width, height = h:get_size()
--        if x1 >= 0 and y1 >= 0 and x1 <= width and y1 <= height then
--            h:get_widget():emit_signal(name, x1, y1, ...)
--        end
--        -- Continue searching in all children.
--        for _, child in ipairs(h:get_children()) do
--            traverse_hierarchy_tree(child, x, y, ...)
--        end
--    end
--    own_widget:connect_signal(name, function(_, x, y, ...)
--        -- Translate to "local" coordinates
--        x = x - offset_x
--        y = y - offset_y
--        -- Figure out which widgets were hit and emit the signal on them
--        traverse_hierarchy_tree(hierarchy, x, y, ...)
--    end)
--end
--
--button_signal("button::press")
--button_signal("button::release")
