-- Global --
capi            = {
    root    = root,
    screen  = screen,
    primary = 2,
    tag     = tag,
    dbus    = dbus,
    button  = button,
    client  = client,
    awesome = awesome,
    mouse   = mouse,
    timer   = timer,
    log     = require("logger"),
    home    = os.getenv("HOME"),
    path    = os.getenv("HOME") .. "/.config/awesome",
    wmapi   = require("wmapi"),
}

local awful     = require("awful")

local beautiful = require("beautiful")
local theme     = require("theme")
beautiful.init(theme)

local keybinds = require("keys.keybinds")
capi.root.keys(keybinds.globalkeys)
capi.root.buttons(keybinds.buttonkeys)

require("notifications")

awful.rules.rules = require("rules")(keybinds.clientkeys, keybinds.buttonkeys)

local apps        = require("autostart")
apps:start()

require("widgets.titlebar")
local wibar     = require("wibar")
local wallpaper = require("wallpaper")

awful.screen.connect_for_each_screen(
        function(s)
            wallpaper:create(s)

            for i, tag in pairs(theme.taglist_icons) do
                awful.tag.add(i, {
                    icon      = tag.icon,
                    icon_only = true,
                    layout    = awful.layout.suit.tile,
                    screen    = s,
                    selected  = i == 1
                })
            end

            wibar:create(s)
        end
)

-- No borders if only one tiled client
--capi.screen.connect_signal("arrange", function(s)
--    for _, c in pairs(s.clients) do
--        if c.maximized == false then
--            c.border_width = 0
--        else
--            c.border_width = beautiful.border_width
--        end
--    end
--end)

capi.tag.connect_signal("property::layout", function(t)
    local current_layout = awful.tag.getproperty(t, "layout")

    if (current_layout == awful.layout.suit.max) then
        t.gap = 0
    else
        t.gap = beautiful.useless_gap
    end
end)

capi.client.connect_signal("manage", function(c)
    if not capi.awesome.startup then
        awful.client.setslave(c)
    end

    if capi.awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

require("awful.autofocus")


--local image = require("image")

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
