local ascreen   = require("awful.screen")
local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local gtable    = require("gears.table")
local spawn     = require("awful.spawn")
local wbutton   = require("awful.widget.button")
local button    = require("awful.button")

local wmapi     = {}

wmapi.event     = require("wmapi.event")
wmapi.timer     = require("wmapi.timer")
wmapi.markup    = require("wmapi.markup")

function wmapi:launcher(args)
    if not args.command and not args.menu then
        return
    end

    local w = wbutton(args)
    if not w then
        return
    end

    local b
    if args.command then
        b = gtable.join(w:buttons(), button({}, 1, nil, function()
            spawn(args.command)
        end))
    elseif args.menu then
        b = gtable.join(w:buttons(), button({}, 1, nil, function()
            --args.menu:toggle()

            args.menu.visible = true
        end))
    end

    w:buttons(b)
    return w
end

function wmapi:checkbox()
    return wibox.widget({
                            type   = "checkbox",
                            widget = wibox.widget.checkbox,
                        })
end

function wmapi:graph(args)
    local args      = args or {}

    local set_color = ({ type = "linear", from = { 0, 0 }, to = { 10, 0 }, stops = { { 0, "#FF5656" }, { 0.5, "#88A175" },
                                                                                     { 1, "#AECF96" } } })

    return wibox.widget({
                            type             = "graph",
                            widget           = wibox.widget.graph,

                            max_value        = args.max_value or 100,

                            background_color = args.background_color or "#00000000",

                            forced_width     = args.forced_width or 50,

                            step_width       = args.step_width or 2,
                            step_spacing     = args.step_spacing or 1,

                            color            = beautiful.fg_normal or set_color
                            --"linear:0,1:#FFFF00,20:0,#FF0000:0.1,#FFFF00:0.4," .. beautiful.fg_normal

                        })
end

function wmapi:imagebox(args)
    local args = args or {}

    return wibox.widget(
            {
                type   = "imagebox",
                widget = wibox.widget.imagebox,
                image  = args.image,
            })
end

function wmapi:piechart(args)
    local args = args or {}

    return wibox.widget({
                            type   = "piechart",
                            widget = wibox.widget.piechart,
                        })
end

function wmapi:progressbar(args)
    local args = args or {}

    return wibox.widget({
                            type   = "progressbar",
                            widget = wibox.widget.progressbar,
                        })
end

function wmapi:separator(args)
    local args = args or {}

    return wibox.widget({
                            type   = "separator",
                            widget = wibox.widget.separator,
                        })
end

function wmapi:slider(args)
    local args = args or {}

    return wibox.widget({
                            type   = "slider",
                            widget = wibox.widget.slider,
                        })
end

function wmapi:systray(args)
    local args = args or {}

    return wibox.widget({
                            type   = "systray",
                            widget = wibox.widget.systray,
                        })
end

function wmapi:textbox(args)
    local args = args or {}

    return wibox.widget({
                            type         = "textbox",
                            widget       = wibox.widget.textbox,

                            markup       = args.markup,
                            text         = args.text,

                            font         = beautiful.font,

                            valign       = args.valign or "center",
                            align        = args.align or "left",

                            forced_width = args.forced_width or 50,

                        })
end

function wmapi:popup(args)
    local args = args or {}

    return awful.popup {
        ontop         = args.ontop or true,
        visible       = args.visible or false,
        shape         = args.shape or gears.shape.rounded_rect,
        border_width  = args.border_width or 1,
        border_color  = args.border_color or beautiful.bg_normal,
        maximum_width = args.maximum_width or 300,
        offset        = args.offset or { y = 5 },
        widget        = args.widget or {}
    }
end

function wmapi:buttons(args)
    local args = args or {}

    if args.widget == nil then
        capi.log:message("Error args.widget = nil")
    else
        args.widget:buttons(
                awful.util.table.join(
                        awful.button({}, args.event or wmapi.event.mouse.button_click_left,
                                     args.func or function()
                                         capi.log:message("Error args.func = nil")
                                     end)
                )
        )
    end
end

function wmapi:textclock(args)
    local args = args or {}

    return wibox.widget({
                            widget = wibox.widget.textclock,
                            type   = "textclock"
                        })
end

function wmapi:layout_align_horizontal(items)
    --local widget = wibox.widget({
    --                                layout = wibox.layout.align.horizontal
    --                            })

    local bg     = wibox.container.background()

    local widget = wibox.layout.align.horizontal()

    for i, item in ipairs(items) do
        --widget:add(item)
        --table.insert(widget, item)
    end

    bg.widget = widget

    return bg
end

function wmapi:table_length(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

function wmapi:isempty(s)
    return s == nil or s == ''
end

function wmapi:find(cmd, str)
    local cmd = "echo \"" .. cmd .. "\" | sed -rn \"s/.*" .. str .. ":\\s+([^ ]+).*/\\1/p\""

    local f   = assert(io.popen(cmd, 'r'))
    local s   = assert(f:read('*a'))
    f:close()

    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
    return s
end

function wmapi:display_primary(s)
    if s == capi.screen[capi.primary] then
        return true
    end

    return false
end

function wmapi:display(index)
    local index = index or capi.primary
    local count = capi.screen.count()
    --display_primary

    if index > count or index < -1 then
        return capi.screen[capi.primary]
    end

    return capi.screen[index]
end

function wmapi:display_index(screen)
    for i = 1, capi.screen.count() do
        if screen == capi.screen[i] then
            return i
        end
    end

    return 1
end

function wmapi:update(timeout, callback)
    local timeout  = timeout or 0.3
    local callback = callback or nil

    if callback then
        return gears.timer {
            timeout   = timeout,
            call_now  = true,
            autostart = true,
            callback  = callback
        }
    end

    return nil
end

function wmapi:mouseCoords()
    local mouse = capi.mouse.coords()

    return {
        x = mouse.x,
        y = mouse.y
    }
end

function wmapi:screenHeight(index)
    local index = index or 1
    local s     = capi.screen[index]

    return s.geometry.height
end

function wmapi:screenWidth(index)
    local index = index or 1
    local s     = capi.screen[index]

    return s.geometry.width
end

function wmapi:container(widget)
    local widget = wibox.widget {
        widget,
        widget = wibox.container.background
    }
    local old_cursor, old_wibox

    widget:connect_signal(
            "mouse::enter",
            function()
                widget.bg = "#ffffff11"
                local w   = _G.mouse.current_wibox
                if w then
                    old_cursor, old_wibox = w.cursor, w
                    w.cursor              = "hand1"
                end
            end
    )

    widget:connect_signal(
            "mouse::leave",
            function()
                widget.bg = "#ffffff00"
                if old_wibox then
                    old_wibox.cursor = old_cursor
                    old_wibox        = nil
                end
            end
    )

    widget:connect_signal(
            "button::press",
            function()
                widget.bg = "#ffffff22"
            end
    )

    widget:connect_signal(
            "button::release",
            function()
                widget.bg = "#ffffff11"
            end
    )

    return widget
end

function wmapi:client_info(c)
    if c then
        capi.log:message(c.name,
                         "tag:       " .. tostring(c.tag),
                         "tags:      " .. tostring(c.tags),
                         "instance:  " .. tostring(c.instance),
                         "class:     " .. tostring(c.class),
                         "screen:    " .. tostring(c.screen),
                         "exec_once: " .. tostring(c.exec_once),
                         "icon:      " .. tostring(c.icon),
                         "width:     " .. tostring(c.width),
                         "height:    " .. tostring(c.height)
        )
    end
end

function wmapi:list_client()
    local list = clients()

    -- TODO
    for i, item in ipairs(list) do
        self:client_info(item)
    end
end

return wmapi
