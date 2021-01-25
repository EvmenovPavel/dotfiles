local setmetatable   = setmetatable
local string         = string
local gears          = require("lib.gears")
local wibox          = require("lib.wibox")
local base           = require("lib.wibox.widget.base")
local ascreen        = require("lib.awful.screen")
local abutton        = require("lib.awful.button")
local beautiful      = require("lib.beautiful")

local calendar_popup = { offset = 0, mt = {} }

local properties     = { "markup", "fg_color", "bg_color", "shape", "padding", "border_width", "border_color", "opacity" }
local styles         = { "year", "month", "yearheader", "monthheader", "header", "weekday", "weeknumber", "normal", "focus" }

local function embed(tprops)
    local function fn (widget, flag, _)
        if flag == "monthheader" and not tprops.monthheader then
            flag = "header"
        end
        local props = tprops[flag]
        -- Markup
        if flag ~= "year" and flag ~= "month" then
            local markup = widget:get_text()
            local m      = props.markup
            if type(m) == "function" then
                markup = m(markup)
            elseif type(m) == "string" and string.find(m, "%s", 1, true) then
                markup = string.format(m, markup)
            end
            widget:set_markup(markup)
        end

        local out = base.make_widget_declarative {
            {
                widget,
                margins = props.padding + props.border_width,
                widget  = wibox.container.margin
            },
            shape              = props.shape or gears.shape.rectangle,
            shape_border_color = props.border_color,
            shape_border_width = props.border_width,
            fg                 = props.fg_color,
            bg                 = props.bg_color,
            opacity            = props.opacity,
            widget             = wibox.container.background
        }
        return out
    end
    return fn
end

local function parse_cell_options(cell, args)
    args           = args or {}
    local props    = {}
    local bl_style = beautiful.calendar_style or {}

    for _, prop in ipairs(properties) do
        local default
        if prop == 'fg_color' then
            default = cell == "focus" and beautiful.fg_focus or beautiful.fg_normal
        elseif prop == 'bg_color' then
            default = cell == "focus" and beautiful.bg_focus or beautiful.bg_normal
        elseif prop == 'padding' then
            default = 2
        elseif prop == 'opacity' then
            default = 1
        elseif prop == 'shape' then
            default = nil
        elseif prop == 'border_width' then
            default = beautiful.border_width or 0
        elseif prop == 'border_color' then
            default = beautiful.border_normal or beautiful.fg_normal
        end

        -- Get default
        props[prop] = args[prop] or beautiful["calendar_" .. cell .. "_" .. prop] or bl_style[prop] or default
    end
    props['markup'] = cell == "focus" and
            (args['markup'] or beautiful["calendar_" .. cell .. "_markup"] or bl_style['markup'] or
                    string.format('<span foreground="%s" background="%s"><b>%s</b></span>',
                                  props['fg_color'], props['bg_color'], "%s")
            )
    return props
end

local function parse_all_options(args)
    args        = args or {}
    local props = {}

    for _, cell in pairs(styles) do
        if cell ~= "monthheader" or args.style_monthheader then
            props[cell] = parse_cell_options(cell, args["style_" .. cell])
        end
    end
    return props
end

local function get_geometry(widget, screen, position)
    local pos           = position or "cc"
    local s             = screen or ascreen.focused()
    local margin        = widget._calendar_margin or 0
    local wa            = s.workarea
    local width, height = widget:fit({ screen = s, dpi = s.dpi }, wa.width, wa.height)

    width               = width < wa.width and width or wa.width
    height              = height < wa.height and height or wa.height


    -- Set to position: pos = tl, tc, tr
    --                        cl, cc, cr
    --                        bl, bc, br
    local x, y
    if pos:sub(1, 1) == "t" then
        y = wa.y + margin
    elseif pos:sub(1, 1) == "b" then
        y = wa.y + wa.height - (height + margin)
    else
        --if pos:sub(1,1) == "c" then
        y = wa.y + math.floor((wa.height - height) / 2)
    end
    if pos:sub(2, 2) == "l" then
        x = wa.x + margin
    elseif pos:sub(2, 2) == "r" then
        x = wa.x + wa.width - (width + margin)
    else
        --if pos:sub(2,2) == "c" then
        x = wa.x + math.floor((wa.width - width) / 2)
    end

    return { x = x, y = y, width = width, height = height }
end

function calendar_popup:call_calendar(offset, position, screen)
    local inc_offset = offset or 0
    local pos        = position or self.position
    local s          = screen or self.screen or ascreen.focused()
    self.position    = pos  -- remember last position when changing offset

    self.offset      = inc_offset ~= 0 and self.offset + inc_offset or 0

    local widget     = self:get_widget()
    local raw_date   = os.date("*t")
    local date       = { day = raw_date.day, month = raw_date.month, year = raw_date.year }
    if widget._private.type == "month" and self.offset ~= 0 then
        local month_offset = (raw_date.month + self.offset - 1) % 12 + 1
        local year_offset  = raw_date.year + math.floor((raw_date.month + self.offset - 1) / 12)
        date               = { month = month_offset, year = year_offset }
    elseif widget._private.type == "year" then
        date = { year = raw_date.year + self.offset }
    end

    widget:set_date(date)
    self:set_screen(s)
    self:geometry(get_geometry(widget, s, pos))
    return self
end

--- Toggle calendar visibility
function calendar_popup:toggle()
    self:call_calendar(0)
    self.visible = not self.visible
end

function calendar_popup:attach(widget, position, args)
    position = position or "tr"
    args     = args or {}
    if args.on_hover == nil then
        args.on_hover = true
    end
    widget:buttons(gears.table.join(
            abutton({ }, 1, function()
                if not self.visible or self._calendar_clicked_on then
                    self:call_calendar(0, position)
                    self.visible = not self.visible
                end
                self._calendar_clicked_on = self.visible
            end),
            abutton({ }, 4, function()
                self:call_calendar(-1)
            end),
            abutton({ }, 5, function()
                self:call_calendar(1)
            end)
    ))
    if args.on_hover then
        widget:connect_signal("mouse::enter", function()
            if not self._calendar_clicked_on then
                self:call_calendar(0, position)
                self.visible = true
            end
        end)
        widget:connect_signal("mouse::leave", function()
            if not self._calendar_clicked_on then
                self.visible = false
            end
        end)
    end
    return self
end

local function get_cal_wibox(caltype, args)
    args      = args or {}

    local ret = wibox { ontop   = true,
                        opacity = args.opacity or 1,
                        bg      = args.bg or gears.color.transparent
    }
    gears.table.crush(ret, calendar_popup, false)

    ret.offset   = 0
    ret.position = args.position or "cc"
    ret.screen   = args.screen

    local widget = wibox.widget {
        font             = args.font or beautiful.font,
        spacing          = args.spacing,
        week_numbers     = args.week_numbers,
        start_sunday     = args.start_sunday,
        long_weekdays    = args.long_weekdays,
        fn_embed         = embed(parse_all_options(args)),
        _calendar_margin = args.margin,
        widget           = caltype == "year" and wibox.widget.calendar.year or wibox.widget.calendar.month
    }
    ret:set_widget(widget)

    ret:buttons(gears.table.join(
            abutton({ }, 1, function()
                ret.visible              = false
                ret._calendar_clicked_on = false
            end),
            abutton({ }, 3, function()
                ret.visible              = false
                ret._calendar_clicked_on = false
            end),
            abutton({ }, 4, function()
                ret:call_calendar(-1)
            end),
            abutton({ }, 5, function()
                ret:call_calendar(1)
            end)
    ))
    return ret
end

function calendar_popup.month(args)
    return get_cal_wibox("month", args)
end

function calendar_popup.year(args)
    return get_cal_wibox("year", args)
end

return setmetatable(calendar_popup, calendar_popup.mt)