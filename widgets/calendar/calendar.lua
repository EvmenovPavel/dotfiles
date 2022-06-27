local awful      = require("awful")
local gears      = require("gears")
local wibox      = require("wibox")
local grid       = require("wibox.layout.grid")
local gmath      = require("gears.math")

local keygrabber = require("awful.keygrabber")
local gtable     = require("gears.table")
local object     = require("gears.object")

local beautiful  = require("beautiful")
local xrdb       = beautiful.xresources.get_current_theme()

local _calendar  = {}

local x          = {
    --           xrdb variable
    background = xrdb.background,
    foreground = xrdb.foreground,
    color0     = xrdb.color0,
    color1     = xrdb.color1,
    color2     = xrdb.color2,
    color3     = xrdb.color3,
    color4     = xrdb.color4,
    color5     = xrdb.color5,
    color6     = xrdb.color6,
    color7     = xrdb.color7,
    color8     = xrdb.color8,
    color9     = xrdb.color9,
    color10    = xrdb.color10,
    color11    = xrdb.color11,
    color12    = xrdb.color12,
    color13    = xrdb.color13,
    color14    = xrdb.color14,
    color15    = xrdb.color15,
}

local styles     = {}
styles.month     = {
    padding      = 20,
    fg_color     = x.color7,
    bg_color     = x.background .. "00",
    border_width = 1,
}

styles.normal    = {}

styles.focus     = {
    fg_color = x.color1,
    bg_color = x.color5 .. 00,
    markup   = function(t)
        return '<b>' .. t .. '</b>'
    end,
}

styles.header    = {
    fg_color = x.color4,
    bg_color = x.color1 .. "00",
    -- markup   = function(t) return '<b>' .. t .. '</b>' end,
    markup   = function(t)
        return '<span font_desc="sans bold 22">' .. t .. '</span>'
    end,
}

styles.weekday   = {
    fg_color = x.color7,
    bg_color = x.color1 .. "00",
    padding  = 3,
    markup   = function(t)
        return '<b>' .. t .. '</b>'
    end,
}

styles.disable   = {
    fg_color = x.color7,
    bg_color = x.color1 .. "00",
    padding  = 3,
    markup   = function(t)
        return '<b>' .. t .. '</b>'
    end,
}

local function theme_calendar(widget, flag, date)
    if flag == 'monthheader' and not styles.monthheader then
        flag = 'header'
    end

    local props = styles[flag] or {}
    if props.markup and widget.get_text and widget.set_markup then
        widget:set_markup(props.markup(widget:get_text()))
    end

    -- Change bg color for weekends
    local d          = {
        year  = date.year,
        month = (date.month or 1),
        day   = (date.day or 1)
    }
    local weekday    = tonumber(os.date('%w', os.time(d)))

    local default_fg = x.color7
    --local default_bg = x.color0 .. "00"
    local default_bg = (weekday == 0 or weekday == 6) and x.color6 or x.color14
    local ret        = wibox.widget({
                                        {
                                            widget,
                                            margins = (props.padding or 2) + (props.border_width or 0),
                                            widget  = wibox.container.margin
                                        },
                                        shape              = props.shape,
                                        shape_border_color = props.border_color or x.background,
                                        shape_border_width = props.border_width or 0,
                                        fg                 = props.fg_color or default_fg,
                                        bg                 = props.bg_color or default_bg,
                                        widget             = wibox.container.background,
                                    })
    return ret
end

local common_args = { w    = wibox.layout.fixed.horizontal(),
                      data = setmetatable({}, { __mode = 'kv' }) }

local wbase       = require("wibox.widget.base")

local function create_test()
    local fg_color     = beautiful.fg_normal
    local bg_color     = beautiful.bg_normal
    local border_width = beautiful.menu_border_width or 0
    local border_color = beautiful.menu_border_color

    local instance     = wibox {
        ontop        = true,
        bg           = bg_color,
        fg           = fg_color,
        border_width = border_width,
        border_color = border_color,
    }

    if instance.visible then
        -- Menu already shown, exit
        return
        --elseif not menubar.cache_entries then
        --    menubar.refresh(scr)
    end

    -- Set position and size

    local scrgeom  = wmapi:screen_geometry()
    local geometry = { height = 10, width = 50 }

    local geometry = { x      = geometry.x or scrgeom.x,
                       y      = 100 or geometry.y or scrgeom.y,

                       height = geometry.height or gmath.round(beautiful.get_font_height() * 2),
                       width  = (geometry.width or scrgeom.width) - border_width * 2 }
    instance:geometry(geometry)

    --current_item     = 1
    --current_category = nil
    --menulist_update(scr)

    --local prompt_args = menubar.prompt_args or {}

    --awful.prompt.run(setmetatable({
    --                                  prompt              = "Run: ",
    --                                  textbox             = instance.prompt.widget,
    --                                  completion_callback = awful.completion.shell,
    --                                  history_path        = gfs.get_cache_dir() .. "/history_menu",
    --                                  done_callback       = menubar.hide,
    --                                  changed_callback    = function(query)
    --                                      instance.query = query
    --                                      menulist_update(scr)
    --                                  end,
    --                                  keypressed_callback = prompt_keypressed_callback
    --                              }, { __index = prompt_args }))

    instance.visible = true
end

local menu     = {}

menu.menu_keys = { up    = { "Up", "k" },
                   down  = { "Down", "j" },
                   back  = { "Left", "h" },
                   exec  = { "Return" },
                   enter = { "Right", "l" },
                   close = { "Escape" } }

local function check_access_key(_menu, key)
    for i, item in ipairs(_menu.items) do
        if item.akey == key then
            _menu:item_enter(i)
            _menu:exec(i, { exec = true })
            return
        end
    end
    if _menu.parent then
        check_access_key(_menu.parent, key)
    end
end

local function grabber(_menu, _, key, event)
    if event ~= "press" then
        return
    end

    local sel = _menu.sel or 0
    if gtable.hasitem(menu.menu_keys.up, key) then
        local sel_new = sel - 1 < 1 and #_menu.items or sel - 1
        _menu:item_enter(sel_new)
    elseif gtable.hasitem(menu.menu_keys.down, key) then
        local sel_new = sel + 1 > #_menu.items and 1 or sel + 1
        _menu:item_enter(sel_new)
    elseif sel > 0 and gtable.hasitem(menu.menu_keys.enter, key) then
        _menu:exec(sel)
    elseif sel > 0 and gtable.hasitem(menu.menu_keys.exec, key) then
        _menu:exec(sel, { exec = true })
    elseif gtable.hasitem(menu.menu_keys.back, key) then
        _menu:hide()
    elseif gtable.hasitem(menu.menu_keys.close, key) then
        menu.get_root(_menu):hide()
    else
        check_access_key(_menu, key)
    end
end

local table_update = function(t, set)
    for k, v in pairs(set) do
        t[k] = v
    end
    return t
end

--return calendar_widget
function _calendar:init(args)
    --create_test()

    local function theme_text(widget, flag, date)
        local props = styles.header

        if props.markup and widget.get_text and widget.set_markup then
            widget:set_markup(props.markup(widget:get_text()))
        end

        local default_fg = x.color7

        local ret        = wibox.widget({
                                            {
                                                widget,
                                                margins = (props.padding or 2) + (props.border_width or 0),
                                                widget  = wibox.container.margin
                                            },
                                            shape              = props.shape,
                                            shape_border_color = props.border_color or x.background,
                                            shape_border_width = props.border_width or 0,
                                            fg                 = props.fg_color or default_fg,
                                            widget             = wibox.container.background
                                        })
        return ret
    end

    local widgetCalendar  = wibox.widget({
                                             date          = os.date("*t"),
                                             font          = beautiful.get_font(),
                                             --fn_embed      = theme_calendar,
                                             long_weekdays = true,
                                             widget        = wmapi:widget():calendar().month,
                                         })

    local widgetMonthName = wibox.widget({
                                             date          = os.date("*t"),
                                             font          = beautiful.get_font(),
                                             --fn_embed      = theme_text,
                                             long_weekdays = true,
                                             widget        = wmapi:widget():calendar().month_name
                                         })

    local btn_next        = wmapi:widget():button()
    local btn_prev        = wmapi:widget():button()

    local widget_grid     = grid()
    widget_grid:set_expand(true)
    widget_grid:set_homogeneous(true)
    widget_grid:set_spacing(10)

    --local w           = btn_prev:get()
    --w.visible         = true

    widget_grid:add_widget_at(btn_prev:get(), 1, 1, 1, 1)
    widget_grid:add_widget_at(widgetMonthName, 1, 2, 1, 1)
    widget_grid:add_widget_at(btn_next:get(), 1, 3, 1, 1)
    widget_grid:add_widget_at(widgetCalendar, 2, 1, 3, 3)

    local layout      = wibox.widget({
                                         --widgetText,
                                         --{
                                         --    {
                                         --        -- <
                                         --        btn_prev:get(),
                                         --        widget = wibox.layout.fixed.horizontal,
                                         --    },
                                         --    {
                                         --        -- month name
                                         --        widgetMonthName,
                                         --        widget = wibox.layout.fixed.horizontal,
                                         --    },
                                         --    {
                                         --        -- >
                                         --        btn_next:get(),
                                         --        widget = wibox.layout.fixed.horizontal,
                                         --    },
                                         --    -- < month_day > --
                                         --    widget = wibox.layout.fixed.horizontal
                                         --},
                                         widget_grid,

                                         widget = wibox.layout.fixed.vertical,
                                     })

    local popupWidget = awful.popup({
                                        ontop        = true,
                                        visible      = false,
                                        shape        = gears.shape.rounded_rect,
                                        offset       = { y = 5 },
                                        border_width = 1,
                                        border_color = "#333333",
                                        widget       = layout
                                    })

    --local btn_next_image = widget:imagebox()
    --btn_next_image:set_image(resources.calendar.next)
    --btn_next_image:set_resize(true)


    btn_next:set_text("asdasd")
    --btn_next:set_image(resources.calendar.next)
    --btn_next:set_wimage(btn_next_image)
    btn_next:set_key(event.mouse.button_click_left)
    btn_next:set_function(
            function()
                local function update(widget)
                    local a = widget:get_date()
                    a.month = a.month + 1
                    widget:set_date(nil)
                    widget:set_date(a)
                end

                update(widgetCalendar)
                --update(widgetText)
                update(widgetMonthName)

                popupWidget:set_widget(nil)
                popupWidget:set_widget(layout)
            end
    )

    --btn_prev:set_image(resources.calendar.prev)
    btn_prev:set_key(event.mouse.button_click_left)
    btn_prev:set_function(
            function()
                local function update(widget)
                    local a = widget:get_date()
                    a.month = a.month - 1
                    widget:set_date(nil)
                    widget:set_date(a)
                end

                update(widgetCalendar)
                --update(widgetText)
                update(widgetMonthName)

                popupWidget:set_widget(nil)
                popupWidget:set_widget(layout)
            end
    )

    local _menu       = table_update(object(), {
        item_enter = menu.item_enter,
        item_leave = menu.item_leave,
        get_root   = menu.get_root,
        delete     = menu.delete,
        update     = menu.update,
        toggle     = menu.toggle,
        hide       = menu.hide,
        show       = menu.show,
        exec       = menu.exec,
        add        = menu.add,
        child      = {},
        items      = {},
        --parent     = parent,
        --layout     = args.layout(),
        --theme      = load_theme(args.theme or {}, parent and parent.theme)
    })

    --if args.auto_expand ~= nil then
    --    _menu.auto_expand = args.auto_expand
    --else
    _menu.auto_expand = true
    --end

    local _keygrabber = function(...)
        grabber(_menu, ...)
    end

    local function toggle()
        if popupWidget.visible then
            widgetCalendar:set_date(nil)
            widgetCalendar:set_date(os.date("*t"))

            --widgetText:set_date(nil)
            --widgetText:set_date(os.date("*t"))

            widgetMonthName:set_date(nil)
            widgetMonthName:set_date(os.date("*t"))

            popupWidget:set_widget(nil)
            popupWidget:set_widget(layout)
            popupWidget.visible = false

            --keygrabber.stop(_keygrabber)
        else
            awful.placement.top_right(popupWidget, {
                margins = {
                    top   = 30,
                    right = 10
                },
                parent  = awful.screen.focused()
            })
            popupWidget.visible = true

            --keygrabber.run(_keygrabber)
        end
    end

    local textclock = wibox.widget({
                                       wibox.widget.textclock(beautiful.datetime, 1),
                                       widget = wibox.layout.fixed.horizontal,
                                   })

    textclock:connect_signal(
            event.signals.button.release,
            function(_, _, _, button)
                if button == event.mouse.button_click_left then
                    toggle()
                end
            end
    )

    --toggle()

    return textclock
end

return setmetatable(_calendar, { __call = function(_, ...)
    return _calendar:init(...)
end })
