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

local calendar   = {}

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

local menu       = {}

menu.menu_keys   = { up    = { "Up", "k" },
                     down  = { "Down", "j" },
                     back  = { "Left", "h" },
                     exec  = { "Return" },
                     enter = { "Right", "l" },
                     close = { "Escape" } }

--return calendar_widget
function calendar:init()
    local w_calendar       = wmapi.widget:calendar()

    local widgetCalendar   = wibox.widget({
        date          = os.date("*t"),
        font          = beautiful.get_font(),
        --fn_embed      = theme_calendar,
        long_weekdays = true,
        widget        = w_calendar.month,
    })

    local widgetMonthName  = wibox.widget({
        date          = os.date("*t"),
        long_weekdays = true,
        forced_width  = 200,
        widget        = wmapi.widget:calendar().month_name
    })

    local btn_next         = wmapi.widget:button()
    local btn_prev         = wmapi.widget:button()

    local widget_btn_title = wibox.widget({
        btn_prev:get(),
        widgetMonthName,
        btn_next:get(),
        layout = wibox.layout.fixed.horizontal,
    })

    local widget           = wibox.widget({
        widget_btn_title,
        widgetCalendar,
        layout = wibox.layout.fixed.vertical,
    })

    local layout           = wibox.widget({
        widget,
        widget = wibox.layout.fixed.vertical,
    })

    local popupWidget      = awful.popup({
        ontop        = true,
        visible      = false,
        --shape        = gears.shape.rounded_rect,
        offset       = { y = 5 },
        border_width = 4,
        border_color = "#333333",
        widget       = layout
    })

    local function update_calendar(widget, count)
        local a = widget:get_date()
        a.month = a.month + count
        widget:set_date(nil)
        widget:set_date(a)
    end

    btn_next:textbox():text(">")
    btn_next:clicked(function()
        update_calendar(widgetCalendar, 1)
        update_calendar(widgetMonthName, 1)

        popupWidget:set_widget(nil)
        popupWidget:set_widget(layout)
    end)

    btn_prev:textbox():text("<")
    btn_prev:clicked(function()
        update_calendar(widgetCalendar, -1)
        update_calendar(widgetMonthName, -1)

        popupWidget:set_widget(nil)
        popupWidget:set_widget(layout)
    end)

    awful.placement.top_right(popupWidget, {
        margins = {
            top   = 30,
            right = 10
        },
        parent  = awful.screen.focused()
    })

    local function toggle()
        if popupWidget.visible then
            widgetCalendar:set_date(nil)
            widgetCalendar:set_date(os.date("*t"))

            popupWidget:set_widget(nil)
            popupWidget:set_widget(layout)

            popupWidget.visible = false
        else
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

    return textclock
end

return setmetatable(calendar, { __call = function(_, ...)
    return calendar:init(...)
end })
