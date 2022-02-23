local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local markup    = capi.markup
local button    = capi.event.signals.button

local calendar  = {}

-- https://codepen.io/internette/pen/YqJEjY

local function rounded_shape(size)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, size)
    end
end

local calendar_themes = {
    nord    = {
        bg             = "#2E3440",
        fg             = "#D8DEE9",
        focus_date_bg  = "#88C0D0",
        focus_date_fg  = "#000000",
        weekend_day_bg = "#3B4252",
        weekday_fg     = "#88C0D0",
        header_fg      = "#E5E9F0",
        border         = "#4C566A"
    },
    outrun  = {
        bg             = "#0d0221",
        fg             = "#D8DEE9",
        focus_date_bg  = "#650d89",
        focus_date_fg  = "#2de6e2",
        weekend_day_bg = "#261447",
        weekday_fg     = "#2de6e2",
        header_fg      = "#f6019d",
        border         = "#261447"
    },
    dark    = {
        bg             = "#000000",
        fg             = "#ffffff",
        focus_date_bg  = "#ffffff",
        focus_date_fg  = "#000000",
        weekend_day_bg = "#444444",
        weekday_fg     = "#ffffff",
        header_fg      = "#ffffff",
        border         = "#333333"
    },
    light   = {
        bg             = "#ffffff",
        fg             = "#000000",
        focus_date_bg  = "#000000",
        focus_date_fg  = "#ffffff",
        weekend_day_bg = "#AAAAAA",
        weekday_fg     = "#000000",
        header_fg      = "#000000",
        border         = "#CCCCCC"
    },
    monokai = {
        bg             = "#272822",
        fg             = "#F8F8F2",
        focus_date_bg  = "#AE81FF",
        focus_date_fg  = "#ffffff",
        weekend_day_bg = "#75715E",
        weekday_fg     = "#FD971F",
        header_fg      = "#F92672",
        border         = "#75715E"
    }
}

local placement       = {
    top       = "top",
    top_right = "top_right",
    top_left  = "top_left"
}

local function init(args)
    local args      = args or {}

    local theme     = args.theme or calendar_themes.dark
    local placement = args.placement or placement.top_right

    local styles    = {
        month   = {
            padding      = 4,
            bg_color     = theme.bg,
            border_width = 0,
        },

        normal  = {
            markup = function(t)
                return t
            end,
            shape  = rounded_shape(4)
        },

        focus   = {
            fg_color = theme.focus_date_fg,
            bg_color = theme.focus_date_bg,
            markup   = function(t)
                return "<b>" .. t .. "</b>"
            end,
            shape    = rounded_shape(4)
        },

        header  = {
            fg_color = theme.header_fg,
            bg_color = theme.bg,
            markup   = function(t)
                return "<b>" .. t .. "</b>"
            end
        },

        weekday = {
            fg_color = theme.weekday_fg,
            bg_color = theme.bg,
            markup   = function(t)
                return "<b>" .. t .. "</b>"
            end,
        }
    }

    local function decorate_cell(widget, flag, date)
        if flag == "monthheader" and not styles.monthheader then
            flag = "header"
        end

        if flag == "focus" then
            local today = os.date("*t")
            if today.month ~= date.month then
                flag = "normal"
            end
        end

        local props = styles[flag] or {}
        if props.markup and widget.get_text and widget.set_markup then
            widget:set_markup(props.markup(widget:get_text()))
        end

        local d          = { year = date.year, month = (date.month or 1), day = (date.day or 1) }
        local weekday    = tonumber(os.date("%w", os.time(d)))
        local default_bg = (weekday == 0 or weekday == 6) and theme.weekend_day_bg or theme.bg
        local ret        = wibox.widget {
            {
                {
                    widget,
                    halign = "center",
                    widget = wibox.container.place
                },
                margins = (props.padding or 2) + (props.border_width or 0),
                widget  = wibox.container.margin
            },
            shape              = props.shape,
            shape_border_color = props.border_color or "#000000",
            shape_border_width = props.border_width or 0,
            fg                 = props.fg_color or theme.fg,
            bg                 = props.bg_color or default_bg,
            widget             = wibox.container.background
        }

        return ret
    end

    local calendarWidget = wibox.widget({
                                            date          = os.date("*t"),
                                            font          = beautiful.get_font(),
                                            fn_embed      = decorate_cell,
                                            long_weekdays = true,
                                            widget        = wibox.widget.calendar.month
                                        })

    local popupWidget    = awful.popup({
                                           ontop        = true,
                                           visible      = false,
                                           shape        = gears.shape.rounded_rect,
                                           offset       = { y = 5 },
                                           border_width = 1,
                                           border_color = theme.border,
                                           widget       = calendarWidget
                                       })

    function toggle()
        if popupWidget.visible then
            calendarWidget:set_date(nil)
            calendarWidget:set_date(os.date("*t"))
            popupWidget:set_widget(nil)
            popupWidget:set_widget(calendarWidget)
            popupWidget.visible = not popupWidget.visible
        else
            if placement == "top" then
                awful.placement.top(popupWidget, { margins = { top = 30 }, parent = awful.screen.focused() })
            elseif placement == "top_right" then
                awful.placement.top_right(popupWidget, { margins = { top = 30, right = 10 }, parent = awful.screen.focused() })
            elseif placement == "bottom_right" then
                awful.placement.bottom_right(popupWidget, { margins = { bottom = 30, right = 10 }, parent = awful.screen.focused() })
            else
                awful.placement.top(popupWidget, { margins = { top = 30 }, parent = awful.screen.focused() })
            end

            popupWidget.visible = true

        end
    end

    local textclock = wibox.widget {
        wibox.widget.textclock(markup.font(beautiful.font, beautiful.datetime), 1),
        widget = wibox.layout.fixed.horizontal,
    }

    textclock:connect_signal(button.release,
                             function()
                                 toggle()
                             end)

    textclock:buttons(
            awful.util.table.join(
                    capi.wmapi:button({
                                          event = mouse.button_click_scroll_down,
                                          func  = function()
                                              local a = calendarWidget:get_date()
                                              a.month = a.month + 1
                                              calendarWidget:set_date(nil)
                                              calendarWidget:set_date(a)
                                              popupWidget:set_widget(calendarWidget)
                                          end
                                      }),
                    capi.wmapi:button({ event = mouse.button_click_scroll,
                                        func  = function()
                                            local a = calendarWidget:get_date()
                                            a.month = a.month - 1
                                            calendarWidget:set_date(nil)
                                            calendarWidget:set_date(a)
                                            popupWidget:set_widget(calendarWidget)
                                        end
                                      })
            )
    )

    return textclock
end

return setmetatable(calendar, { __call = function(_, ...)
    return init(...)
end })
