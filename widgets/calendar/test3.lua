local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local grid      = require("wibox.layout.grid")

local beautiful = require("beautiful")
local xrdb      = beautiful.xresources.get_current_theme()

local calendar  = require("widgets.calendar.calendar")

local test3     = {}

local x         = {
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

local styles    = {}
styles.month    = {
    padding      = 20,
    fg_color     = x.color7,
    bg_color     = x.background .. "00",
    border_width = 1,
}

styles.normal   = {}

styles.focus    = {
    fg_color = x.color1,
    bg_color = x.color5 .. 00,
    markup   = function(t) return '<b>' .. t .. '</b>' end,
}

styles.header   = {
    fg_color = x.color4,
    bg_color = x.color1 .. "00",
    -- markup   = function(t) return '<b>' .. t .. '</b>' end,
    markup   = function(t) return '<span font_desc="sans bold 22">' .. t .. '</span>' end,
}

styles.weekday  = {
    fg_color = x.color7,
    bg_color = x.color1 .. "00",
    padding  = 3,
    markup   = function(t) return '<b>' .. t .. '</b>' end,
}

styles.disable  = {
    fg_color = x.color7,
    bg_color = x.color1 .. "00",
    padding  = 3,
    markup   = function(t) return '<b>' .. t .. '</b>' end,
}

--return calendar_widget
function test3:init(args)
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
                                             widget        = calendar.month,
                                         })

    local widgetMonthName = wibox.widget({
                                             date          = os.date("*t"),
                                             font          = beautiful.get_font(),
                                             --fn_embed      = theme_text,
                                             long_weekdays = true,
                                             widget        = calendar.month_name
                                         })

    local btn_next        = widget:button()
    local btn_prev        = widget:button()

    local widget_grid     = grid()
    widget_grid:set_expand(true)
    widget_grid:set_homogeneous(true)
    widget_grid:set_spacing(10)

    widget_grid:add_widget_at(btn_prev:get(), 1, 1, 1, 1)
    widget_grid:add_widget_at(widgetMonthName, 1, 2, 1, 1)
    widget_grid:add_widget_at(btn_next:get(), 1, 3, 1, 1)
    widget_grid:add_widget_at(widgetCalendar, 2, 1, 3, 3)

    local layout         = wibox.widget({
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

    local popupWidget    = awful.popup({
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
    btn_next:set_func(
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
    btn_prev:set_func(
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
        else
            awful.placement.top_right(popupWidget, {
                margins = {
                    top   = 30,
                    right = 10
                },
                parent  = awful.screen.focused()
            })
            popupWidget.visible = true
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

    toggle()

    return textclock
end

return setmetatable(test3, { __call = function(_, ...)
    return test3:init(...)
end })
