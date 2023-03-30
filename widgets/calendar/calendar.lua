local awful     = require("awful")
local wibox     = require("wibox")

local beautiful = require("beautiful")

local calendar  = {}

function calendar:init()
    local w_calendar = wibox.widget({
        date          = os.date("*t"),
        font          = beautiful.get_font(),
        --fn_embed      = theme_calendar,
        long_weekdays = true,
        widget        = wmapi.widget:calendar().month,
    })

    local widget_month_name = wibox.widget({
        date          = os.date("*t"),
        long_weekdays = true,
        forced_width  = 200,
        widget        = wmapi.widget:calendar().month_name
    })

    local btn_next         = wmapi.widget:button()
    local btn_prev         = wmapi.widget:button()

    local widget_btn_title  = wibox.widget({
        btn_prev:get(),
        widget_month_name,
        btn_next:get(),
        layout = wibox.layout.fixed.horizontal,
    })

    local widget     = wibox.widget({
        widget_btn_title,
        w_calendar,
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

    local textbox_next = btn_next:textbox()
    textbox_next:set_text(">")
    btn_next:clicked(function()
        update_calendar(w_calendar, 1)
        update_calendar(widget_month_name, 1)

        popupWidget:set_widget(nil)
        popupWidget:set_widget(layout)
    end)

    local textbox_prev = btn_prev:textbox()
    textbox_prev:set_text("<")
    btn_prev:clicked(function()
        update_calendar(w_calendar, -1)
        update_calendar(widget_month_name, -1)

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
            w_calendar:set_date(nil)
            w_calendar:set_date(os.date("*t"))

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
