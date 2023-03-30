---------------------------------------------------------------------------
--%a    abbreviated weekday name (e.g., Wed)
--%A	full weekday name (e.g., Wednesday)
--%b	abbreviated month name (e.g., Sep)
--%B	full month name (e.g., September)
--%c	date and time (e.g., 09/16/98 23:48:10)
--%d	day of the month (16) [01-31]
--%H	hour, using a 24-hour clock (23) [00-23]
--%I	hour, using a 12-hour clock (11) [01-12]
--%M	minute (48) [00-59]
--%m	month (09) [01-12]
--%p	either "am" or "pm" (pm)
--%S	second (10) [00-61]
--%w	weekday (3) [0-6 = Sunday-Saturday]
--%x	date (e.g., 09/16/98)
--%X	time (e.g., 23:48:10)
--%Y	full year (1998)
--%y	two-digit year (98) [00-99]
--%%	the character `%´
---------------------------------------------------------------------------

local gtable      = require("gears.table")
local vertical    = require("wibox.layout.fixed").vertical
local grid        = require("wibox.layout.grid")
local bgcontainer = require("wibox.container.background")
local base        = require("wibox.widget.base")
local beautiful   = require("beautiful")
local wibox       = require("wibox")
local gears       = require("gears")

local calendar    = { mt = {} }

local properties  = { "date", "font", "spacing", "week_numbers", "start_sunday", "long_weekdays", "fn_embed" }

local align       = {
    center = "center",
    right  = "right",
    left   = "left"
}

--- Make a textbox
-- @tparam string text Text of the textbox
-- @tparam string font Font of the text
-- @tparam boolean center Center the text horizontally
-- @treturn wibox.widget.textbox
local function make_cell(text, font, _align)
    local w_textbox = wmapi.widget:textbox()

    w_textbox:set_markup(text)
    w_textbox:set_align(_align or align.center)
    w_textbox:set_valign(align.center)
    w_textbox:set_font(font)

    return w_textbox
end

--- Create a grid layout with the month calendar
-- @tparam table props Table of calendar properties
-- @tparam table date Date table
-- @tparam number date.year Date year
-- @tparam number date.month Date month
-- @tparam number|nil date.day Date day
-- @treturn widget Grid layout
local function create_month(props, date)
    local num_columns = props.week_numbers and 8 or 7

    -- Create grid layout
    local layout      = grid()
    layout:set_expand(true)
    layout:set_homogeneous(true)
    layout:set_spacing(props.spacing)
    layout:set_forced_num_cols(num_columns)

    -- со 2 позиции начинается нумерация дат в гриде
    local start_row      = 2
    -- с какого дня начинается старт даты
    local start_column   = num_columns - 6
    -- воскресенье находится в начале или в конце
    local week_start     = props.start_sunday and 1 or 2
    -- получаем последнюю дату текущего месяца
    local last_day       = os.date("*t", os.time({ year = date.year, month = date.month + 1, day = 0 }))
    -- получаем последнюю дату предыдущего месяца
    local last_day_start = os.date("*t", os.time({ year = date.year, month = date.month, day = 0 })).day
    -- получаем текущий месяц
    local current_month  = os.date("*t").month

    -- получаем последнюю дату (число)
    local month_days     = last_day.day
    -- получаем количество колонок для дат
    local column_fday    = (last_day.wday - month_days + 1 - week_start) % 7

    local cell_date, ostime, i, j, text, flag, j_end_to_start

    -- Days
    i                    = start_row
    -- с какого дня недели начинаем старт (пн, вт, ср ... вс)
    j                    = column_fday + start_column
    -- заполняем пустые колонки, которые отвечают
    -- за предыдущий месяц
    j_end_to_start       = j - 1

    local current_week   = nil
    local drawn_weekdays = 0

    for day = 1, month_days do
        cell_date = { year = date.year, month = date.month, day = day }
        ostime    = os.time(cell_date)

        -- Week number
        if props.week_numbers then
            text = os.date("%V", ostime)

            if tonumber(text) ~= current_week then
                flag = "weeknumber"
                text = props.fn_embed(make_cell(text, props.font, align.right), flag, cell_date)
                layout:add_widget_at(text, i, 1, 1, 1)
                current_week = tonumber(text)
            end
        end

        -- Week days
        if drawn_weekdays < 7 then
            flag = "weekday"
            text = os.date("%a", ostime)

            if not props.long_weekdays then
                text = string.sub(text, 1, 2)
            end

            text = props.fn_embed(make_cell(text, props.font, align.right), flag, cell_date)
            layout:add_widget_at(text, 1, j, 1, 1)
            drawn_weekdays = drawn_weekdays + 1
        end

        --if props.show_last_day then
        -- Week last days
        if j_end_to_start > 0 then
            for i_column = j_end_to_start, 1, -1 do
                flag = "disable"
                text = string.format("%2d", last_day_start)

                text = props.fn_embed(make_cell(text, props.font, align.right), flag, cell_date)

                layout:add_widget_at(text, i, i_column, 1, 1)

                last_day_start = last_day_start - 1
                --j_end          = j_end - 1
            end

            j_end_to_start = 0
        end
        --end

        -- Normal day
        flag = "normal"
        text = string.format("%2d", day)

        -- Focus day
        if date.day == day and date.month == current_month then
            flag = "focus"
            text = "<b>" .. text .. "</b>"
        end

        text = props.fn_embed(make_cell(text, props.font, align.right), flag, cell_date)

        layout:add_widget_at(text, i, j, 1, 1)

        -- find next cell
        i, j = layout:get_next_empty(i, j)

        if j < start_column then
            j = start_column
        end
    end

    --if props.show_last_day then
    local i_break = 0
    if j == 1 then
        i_break = i
    else
        i_break = i + 1
    end

    for day = 1, month_days do
        flag = "disable"
        text = string.format("%2d", day)

        text = props.fn_embed(make_cell(text, props.font, align.right), flag, cell_date)
        layout:add_widget_at(text, i, j, 1, 1)

        i, j = layout:get_next_empty(i, j)

        if j < start_column then
            j = start_column
        end

        if i > i_break then
            break
        end
    end
    --end

    return layout --props.fn_embed(layout, "month", date)
end

--- Create a grid layout for the year calendar
-- @tparam table props Table of year calendar properties
-- @param date Year to display (number or string)
-- @treturn widget Grid layout
local function create_years(props, date)
    -- Create a grid widget with the 12 months
    local in_layout = grid()
    in_layout:set_expand(true)
    in_layout:set_homogeneous(true)
    in_layout:set_spacing(2 * props.spacing)
    in_layout:set_forced_num_cols(4)
    in_layout:set_forced_num_rows(3)

    local month_date
    local current_date = os.date("*t")

    for month = 1, 12 do
        if date.year == current_date.year and month == current_date.month then
            month_date = { day = current_date.day, month = current_date.month, year = current_date.year }
        else
            month_date = { month = month, year = date.year }
        end

        in_layout:add(create_month(props, month_date))
    end

    -- Create a vertical layout
    local flag, text  = "yearheader", string.format("%s", date.year)
    local year_header = props.fn_embed(make_cell(text, props.font), flag, date)

    local out_layout  = vertical()
    out_layout:set_spacing(2 * props.spacing) -- separate header from calendar grid
    out_layout:add(year_header)
    out_layout:add(in_layout)

    return props.fn_embed(out_layout, "year", date)
end

local function create_year(props, date)
    local t, w, flag, text

    -- Header
    t            = os.time({ year = date.year, month = date.month, day = 1 })
    text         = os.date("%Y", t)
    flag         = "yearheader"
    w            = props.fn_embed(make_cell(text, props.font, align.left), flag, date)

    -- Create layout
    local layout = wibox.widget({
        w,
        widget = wibox.layout.fixed.vertical
    })
    layout:set_spacing(props.spacing)

    return layout --props.fn_embed(layout, "text", date)
end

local function create_day(props, date)
    local t, w, flag, text

    -- Header
    t            = os.time({ year = date.year, month = date.month, day = 1 })
    text         = tonumber(os.date("%d", t))

    flag         = "dayheader"
    w            = props.fn_embed(make_cell(text, props.font, align.left), flag, date)

    -- Create layout
    local layout = wibox.widget({
        w,
        widget = wibox.layout.fixed.vertical
    })
    layout:set_spacing(props.spacing)

    return layout --props.fn_embed(layout, "text", date)
end

local function create_day_name(props, date)
    local t, w, flag, text

    -- Header
    t            = os.time({ year = date.year, month = date.month, day = 1 })
    text         = os.date("%A", t)
    flag         = "daynameheader"
    w            = props.fn_embed(make_cell(text, props.font, align.left), flag, date)

    -- Create layout
    local layout = wibox.widget({
        w,
        widget = wibox.layout.fixed.vertical
    })
    layout:set_spacing(props.spacing)

    return layout --props.fn_embed(layout, "text", date)
end

local function create_month_name(props, date)
    local t, w, flag, text

    -- Header
    t            = os.time({ year = date.year, month = date.month, day = 1 })
    text         = os.date("%B", t)
    flag         = "monthnameheader"
    w            = props.fn_embed(make_cell(text, props.font, align.center), flag, date)

    -- Create layout
    local layout = wibox.widget({
        w,
        widget = wibox.layout.fixed.vertical
    })
    layout:set_spacing(props.spacing)

    return layout --props.fn_embed(layout, "text", date)
end

local function create_full_name(props, date)

end

--- Set the container to the current date
-- @param self Widget to update
local function fill_container(self)
    local date = self._private.date

    if date then
        -- Create calendar grid
        if self._private.type == "month" then
            self._private.container:set_widget(create_month(self._private, date))
        elseif self._private.type == "years" then
            self._private.container:set_widget(create_years(self._private, date))
        elseif self._private.type == "year" then
            self._private.container:set_widget(create_year(self._private, date))
        elseif self._private.type == "day" then
            self._private.container:set_widget(create_day(self._private, date))
        elseif self._private.type == "dayname" then
            self._private.container:set_widget(create_day_name(self._private, date))
        elseif self._private.type == "monthname" then
            self._private.container:set_widget(create_month_name(self._private, date))
        elseif self._private.type == "fullname" then
            self._private.container:set_widget(create_full_name(self._private, date))
        end
    else
        self._private.container:set_widget(nil)
    end

    self:emit_signal("widget::layout_changed")
end

-- Set the calendar date
function calendar:set_date(date)
    if date ~= self._private.date then
        self._private.date = date
        -- (Re)create calendar grid
        fill_container(self)
    end
end

-- Build properties function
for _, prop in ipairs(properties) do
    -- setter
    if not calendar["set_" .. prop] then
        calendar["set_" .. prop] = function(self, value)
            if (string.sub(prop, 1, 3) == "fn_" and type(value) == "function") or self._private[prop] ~= value then
                self._private[prop] = value
                -- (Re)create calendar grid
                fill_container(self)
            end
        end
    end

    -- getter
    if not calendar["get_" .. prop] then
        calendar["get_" .. prop] = function(self)
            return self._private[prop]
        end
    end
end

--- Return a new calendar widget by type.
--
-- @tparam string type Type of the calendar, `year` or `month`
-- @tparam table date Date of the calendar
-- @tparam number date.year Date year
-- @tparam number|nil date.month Date month
-- @tparam number|nil date.day Date day
-- @tparam[opt="Monospace 10"] string font Font of the calendar
-- @treturn widget The calendar widget
local function get_calendar(type, date, font)
    local ct  = bgcontainer()
    local ret = base.make_widget(ct, "calendar", { enable_properties = true })

    gtable.crush(ret, calendar, true)

    ret._private.type          = type
    ret._private.container     = ct

    -- default values
    ret._private.date          = date
    ret._private.font          = font or beautiful.calendar_font or "Monospace 10"

    ret._private.spacing       = beautiful.calendar_spacing or 5
    ret._private.week_numbers  = beautiful.calendar_week_numbers or false
    ret._private.start_sunday  = beautiful.calendar_start_sunday or false
    ret._private.long_weekdays = beautiful.calendar_long_weekdays or false
    ret._private.show_last_day = beautiful.calendar_show_last_day or false
    ret._private.fn_embed      = function(w, _)
        return w
    end

    fill_container(ret)

    return ret
end

--- A month calendar widget.
--
-- A calendar widget is a grid containing the calendar for one month.
-- If the day is specified in the date, its cell is highlighted.
--
--@DOC_wibox_widget_calendar_month_EXAMPLE@
-- @tparam table date Date of the calendar
-- @tparam number date.year Date year
-- @tparam number date.month Date month
-- @tparam number|nil date.day Date day
-- @tparam[opt="Monospace 10"] string font Font of the calendar
-- @treturn widget The month calendar widget
-- @function wibox.widget.calendar.month
function calendar:month(date, font)
    return get_calendar("month", date, font)
end

--- A text calendar widget.
-- @function wibox.widget.calendar.years
function calendar:years(date, font)
    return get_calendar("years", date, font)
end

--- A text calendar widget.
-- @function wibox.widget.calendar.text
function calendar:day(date, font)
    return get_calendar("day", date, font)
end

--- A text calendar widget.
-- @function wibox.widget.calendar.day_name
function calendar:year(date, font)
    return get_calendar("year", date, font)
end

--- A text calendar widget.
-- @function wibox.widget.calendar.day_name
function calendar:day_name(date, font)
    return get_calendar("dayname", date, font)
end

--- A text calendar widget.
-- @function wibox.widget.calendar.month_name
function calendar:month_name(date, font)
    return get_calendar("monthname", date, font)
end

--return setmetatable(calendar, calendar.mt)
return setmetatable(calendar, { __call = function()
    return calendar
end })
