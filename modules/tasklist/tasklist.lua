local awful        = require("awful")
local wibox        = require("wibox")
local gears        = require("gears")
local ipairs       = ipairs
local setmetatable = setmetatable
local table        = table
local common       = require("awful.widget.common")
local beautiful    = require("beautiful")
local tag          = require("awful.tag")
local flex         = require("wibox.layout.flex")
local timer        = require("gears.timer")
local gcolor       = require("gears.color")
local gstring      = require("gears.string")
local gdebug       = require("gears.debug")
local base         = require("wibox.widget.base")

local capi         = {
    screen = screen,
    client = client
}

local function get_screen(s)
    return s and screen[s]
end

local w_tasklist                     = { mt = {} }

local instances

w_tasklist.filter, w_tasklist.source = {}, {}

local function tasklist_label(c, args, tb)
    if not args then
        args = {}
    end

    local theme                 = beautiful.get()
    local align                 = args.align or theme.tasklist_align or "left"
    local fg_normal             = gcolor.ensure_pango_color(args.fg_normal or theme.tasklist_fg_normal or theme.fg_normal, "white")
    local bg_normal             = args.bg_normal or theme.tasklist_bg_normal or theme.bg_normal or "#000000"
    local fg_focus              = gcolor.ensure_pango_color(args.fg_focus or theme.tasklist_fg_focus or theme.fg_focus, fg_normal)
    local bg_focus              = args.bg_focus or theme.tasklist_bg_focus or theme.bg_focus or bg_normal
    local fg_urgent             = gcolor.ensure_pango_color(args.fg_urgent or theme.tasklist_fg_urgent or theme.fg_urgent,
                                                            fg_normal)
    local bg_urgent             = args.bg_urgent or theme.tasklist_bg_urgent or theme.bg_urgent or bg_normal
    local fg_minimize           = gcolor.ensure_pango_color(args.fg_minimize or theme.tasklist_fg_minimize or theme.fg_minimize,
                                                            fg_normal)
    local bg_minimize           = args.bg_minimize or theme.tasklist_bg_minimize or theme.bg_minimize or bg_normal
    -- FIXME v5, remove the fallback theme.bg_image_* variables, see GH#1403
    local bg_image_normal       = args.bg_image_normal or theme.tasklist_bg_image_normal or theme.bg_image_normal
    local bg_image_focus        = args.bg_image_focus or theme.tasklist_bg_image_focus or theme.bg_image_focus
    local bg_image_urgent       = args.bg_image_urgent or theme.tasklist_bg_image_urgent or theme.bg_image_urgent
    local bg_image_minimize     = args.bg_image_minimize or theme.tasklist_bg_image_minimize or theme.bg_image_minimize
    local tasklist_disable_icon = args.tasklist_disable_icon or theme.tasklist_disable_icon or false
    local disable_task_name     = args.disable_task_name or theme.tasklist_disable_task_name or false
    local font                  = args.font or theme.tasklist_font or theme.font or ""
    local font_focus            = args.font_focus or theme.tasklist_font_focus or theme.font_focus or font or ""
    local font_minimized        = args.font_minimized or theme.tasklist_font_minimized or theme.font_minimized or font or ""
    local font_urgent           = args.font_urgent or theme.tasklist_font_urgent or theme.font_urgent or font or ""
    local text                  = ""
    local name                  = ""
    local bg
    local bg_image
    local shape                 = args.shape or theme.tasklist_shape
    local shape_border_width    = args.shape_border_width or theme.tasklist_shape_border_width
    local shape_border_color    = args.shape_border_color or theme.tasklist_shape_border_color

    -- symbol to use to indicate certain client properties
    local sticky                = args.sticky or theme.tasklist_sticky or "▪"
    local ontop                 = args.ontop or theme.tasklist_ontop or '⌃'
    local above                 = args.above or theme.tasklist_above or '▴'
    local below                 = args.below or theme.tasklist_below or '▾'
    local floating              = args.floating or theme.tasklist_floating or '✈'
    local maximized             = args.maximized or theme.tasklist_maximized or '<b>+</b>'
    local maximized_horizontal  = args.maximized_horizontal or theme.tasklist_maximized_horizontal or '⬌'
    local maximized_vertical    = args.maximized_vertical or theme.tasklist_maximized_vertical or '⬍'

    if tb then
        tb:set_align(align)
    end

    if not theme.tasklist_plain_task_name then
        if c.sticky then
            name = name .. sticky
        end

        if c.ontop then
            name = name .. ontop
        elseif c.above then
            name = name .. above
        elseif c.below then
            name = name .. below
        end

        if c.maximized then
            name = name .. maximized
        else
            if c.maximized_horizontal then
                name = name .. maximized_horizontal
            end
            if c.maximized_vertical then
                name = name .. maximized_vertical
            end
            if c.floating then
                name = name .. floating
            end
        end
    end

    if not disable_task_name then
        if c.minimized then
            name = name .. (gstring.xml_escape(c.icon_name) or gstring.xml_escape(c.name) or
                    gstring.xml_escape("<untitled>"))
        else
            name = name .. (gstring.xml_escape(c.name) or gstring.xml_escape("<untitled>"))
        end
    end

    local focused = capi.client.focus == c
    -- Handle transient_for: the first parent that does not skip the taskbar
    -- is considered to be focused, if the real client has skip_taskbar.
    if not focused and capi.client.focus and capi.client.focus.skip_taskbar
            and capi.client.focus:get_transient_for_matching(function(cl)
        return not cl.skip_taskbar
    end) == c then
        focused = true
    end

    if focused then
        bg       = bg_focus
        text     = text .. "<span color='" .. fg_focus .. "'>" .. name .. "</span>"
        bg_image = bg_image_focus
        font     = font_focus

        if args.shape_focus or theme.tasklist_shape_focus then
            shape = args.shape_focus or theme.tasklist_shape_focus
        end

        if args.shape_border_width_focus or theme.tasklist_shape_border_width_focus then
            shape_border_width = args.shape_border_width_focus or theme.tasklist_shape_border_width_focus
        end

        if args.shape_border_color_focus or theme.tasklist_shape_border_color_focus then
            shape_border_color = args.shape_border_color_focus or theme.tasklist_shape_border_color_focus
        end
    elseif c.urgent then
        bg       = bg_urgent
        text     = text .. "<span color='" .. fg_urgent .. "'>" .. name .. "</span>"
        bg_image = bg_image_urgent
        font     = font_urgent

        if args.shape_urgent or theme.tasklist_shape_urgent then
            shape = args.shape_urgent or theme.tasklist_shape_urgent
        end

        if args.shape_border_width_urgent or theme.tasklist_shape_border_width_urgent then
            shape_border_width = args.shape_border_width_urgent or theme.tasklist_shape_border_width_urgent
        end

        if args.shape_border_color_urgent or theme.tasklist_shape_border_color_urgent then
            shape_border_color = args.shape_border_color_urgent or theme.tasklist_shape_border_color_urgent
        end
    elseif c.minimized then
        bg       = bg_minimize
        text     = text .. "<span color='" .. fg_minimize .. "'>" .. name .. "</span>"
        bg_image = bg_image_minimize
        font     = font_minimized

        if args.shape_minimized or theme.tasklist_shape_minimized then
            shape = args.shape_minimized or theme.tasklist_shape_minimized
        end

        if args.shape_border_width_minimized or theme.tasklist_shape_border_width_minimized then
            shape_border_width = args.shape_border_width_minimized or theme.tasklist_shape_border_width_minimized
        end

        if args.shape_border_color_minimized or theme.tasklist_shape_border_color_minimized then
            shape_border_color = args.shape_border_color_minimized or theme.tasklist_shape_border_color_minimized
        end
    else
        bg       = bg_normal
        text     = text .. "<span color='" .. fg_normal .. "'>" .. name .. "</span>"
        bg_image = bg_image_normal
    end

    if tb then
        tb:set_font(font)
    end

    local other_args = {
        shape              = shape,
        shape_border_width = shape_border_width,
        shape_border_color = shape_border_color,
    }

    return c, text, bg, bg_image, not tasklist_disable_icon and c.icon or nil, other_args
end

local function tasklist_update(s, w, buttons, filter, data, style, update_function, args)
    local clients = {}

    local source  = args and args.source or w_tasklist.source.all_clients or nil
    local list    = source and source(s, args) or capi.client.get()

    for _, c in ipairs(list) do
        if not (c.skip_taskbar or c.hidden
                or c.type == "splash" or c.type == "dock" or c.type == "desktop")
                and filter(c, s) then
            table.insert(clients, c)
        end
    end

    local function label(c, tb)
        return tasklist_label(c, style, tb)
    end

    update_function(w, buttons, label, data, clients, args)
end

function w_tasklist.new(args, filter, buttons, style, update_function, base_widget)
    local screen   = nil

    local argstype = type(args)

    -- Detect the old function signature
    if argstype == "number" or argstype == "screen" or
            (argstype == "table" and args.index and args == capi.screen[args.index]) then
        gdebug.deprecate("The `screen` paramater is deprecated, use `args.screen`.",
                         { deprecated_in = 5 })

        screen = get_screen(args)
        args   = {}
    end

    assert(type(args) == "table")

    for k, v in pairs { filter          = filter,
                        buttons         = buttons,
                        style           = style,
                        update_function = update_function,
                        layout          = base_widget
    } do
        gdebug.deprecate("The `awful.widget.tasklist()` `" .. k
                                 .. "` paramater is deprecated, use `args." .. k .. "`.",
                         { deprecated_in = 5 })
        args[k] = v
    end

    screen        = screen or get_screen(args.screen)
    local uf      = args.update_function or common.list_update
    local w       = base.make_widget_from_value(args.layout or flex.horizontal)

    local data    = setmetatable({}, { __mode = 'k' })

    local spacing = args.style and args.style.spacing or args.layout and args.layout.spacing
            or beautiful.tasklist_spacing
    if w.set_spacing and spacing then
        w:set_spacing(spacing)
    end

    local queued_update = false

    -- For the tests
    function w._do_tasklist_update_now()
        queued_update = false
        if screen.valid then
            tasklist_update(screen, w, args.buttons, args.filter, data, args.style, uf, args)
        end
    end

    function w._do_tasklist_update()
        -- Add a delayed callback for the first update.
        if not queued_update then
            timer.delayed_call(w._do_tasklist_update_now)
            queued_update = true
        end
    end

    function w._unmanage(c)
        data[c] = nil
    end

    if instances == nil then
        instances = setmetatable({}, { __mode = "k" })

        local function us(s)
            local i = instances[get_screen(s)]
            if i then
                for _, tlist in pairs(i) do
                    tlist._do_tasklist_update()
                end
            end
        end

        local function u()
            for s in pairs(instances) do
                if s.valid then
                    us(s)
                end
            end
        end

        tag.attached_connect_signal(nil, "property::selected", u)
        tag.attached_connect_signal(nil, "property::activated", u)

        capi.client.connect_signal("property::urgent", u)
        capi.client.connect_signal("property::sticky", u)
        capi.client.connect_signal("property::ontop", u)
        capi.client.connect_signal("property::above", u)
        capi.client.connect_signal("property::below", u)
        capi.client.connect_signal("property::floating", u)
        capi.client.connect_signal("property::maximized_horizontal", u)
        capi.client.connect_signal("property::maximized_vertical", u)
        capi.client.connect_signal("property::maximized", u)
        capi.client.connect_signal("property::minimized", u)
        capi.client.connect_signal("property::name", u)
        capi.client.connect_signal("property::icon_name", u)
        capi.client.connect_signal("property::icon", u)
        capi.client.connect_signal("property::skip_taskbar", u)
        capi.client.connect_signal("property::screen", function(c, old_screen)
            us(c.screen)
            us(old_screen)
        end)

        capi.client.connect_signal("property::hidden", u)
        capi.client.connect_signal("tagged", u)
        capi.client.connect_signal("untagged", u)
        capi.client.connect_signal("unmanage", function(c)
            u(c)
            for _, i in pairs(instances) do
                for _, tlist in pairs(i) do
                    tlist._unmanage(c)
                end
            end
        end)

        capi.client.connect_signal("list", u)
        capi.client.connect_signal("focus", u)
        capi.client.connect_signal("unfocus", u)
        capi.screen.connect_signal("removed", function(s)
            instances[get_screen(s)] = nil
        end)
    end

    w._do_tasklist_update()

    local list = instances[screen]
    if not list then
        list              = setmetatable({}, { __mode = "v" })
        instances[screen] = list
    end

    table.insert(list, w)

    return w
end

function w_tasklist.filter.allscreen()
    return true
end

function w_tasklist.filter.alltags(c, screen)
    -- Only print client on the same screen as this widget
    return get_screen(c.screen) == get_screen(screen)
end

function w_tasklist.filter.currenttags(c, screen)
    screen = get_screen(screen)
    -- Only print client on the same screen as this widget
    if get_screen(c.screen) ~= screen then
        return false
    end
    -- Include sticky client too
    if c.sticky then
        return true
    end
    local tags = screen.tags
    for _, t in ipairs(tags) do
        if t.selected then
            local ctags = c:tags()
            for _, v in ipairs(ctags) do
                if v == t then
                    return true
                end
            end
        end
    end
    return false
end

function w_tasklist.filter.minimizedcurrenttags(c, screen)
    screen = get_screen(screen)
    -- Only print client on the same screen as this widget
    if get_screen(c.screen) ~= screen then
        return false
    end
    -- Check client is minimized
    if not c.minimized then
        return false
    end
    -- Include sticky client
    if c.sticky then
        return true
    end
    local tags = screen.tags
    for _, t in ipairs(tags) do
        -- Select only minimized clients
        if t.selected then
            local ctags = c:tags()
            for _, v in ipairs(ctags) do
                if v == t then
                    return true
                end
            end
        end
    end
    return false
end

function w_tasklist.filter.focused(c, screen)
    return get_screen(c.screen) == get_screen(screen) and capi.client.focus == c
end

function w_tasklist.source.all_clients()
    return capi.client.get()
end

local tasklist = {}

local function create_buttons(buttons, object)
    if buttons then
        local btns = {}
        for _, b in ipairs(buttons) do
            -- Create a proxy button object: it will receive the real
            -- press and release events, and will propagate them to the
            -- button object the user provided, but with the object as
            -- argument.
            local btn = button { modifiers = b.modifiers, button = b.button }
            btn:connect_signal("press",
                               function()
                                   b:emit_signal("press", object)
                               end
            )
            btn:connect_signal("release",
                               function()
                                   b:emit_signal("release", object)
                               end
            )
            btns[#btns + 1] = btn
        end

        return btns
    end
end

local function update_function(widget, buttons, label, data, objects)
    -- update the widgets, creating them if needed
    widget:reset()
    for i, o in ipairs(objects) do
        local cache = data[o]
        local ib_icon, w_bm_close, tb_text, bgb_item, w_bm_text, w_bm_icon, w_text, bg_clickable

        if cache then
            ib_icon   = cache.ib
            tb_text   = cache.tb
            bgb_item  = cache.bgb
            w_bm_text = cache.tbm
            w_bm_icon = cache.ibm
            w_text    = cache.tt
        else
            -- CLOSE
            w_bm_close = wmapi:container()
            w_bm_close:set_widget(wibox.widget {
                {
                    widget = wibox.widget.imagebox,
                    image  = resources.path .. "/close.svg",
                    resize = true,
                },
                left   = 5, right = 5,
                top    = 5, bottom = 5,
                widget = wibox.container.margin,
            })
            w_bm_close.shape = gears.shape.circle
            w_bm_close       = wibox.container.margin(w_bm_close, 4, 4, 4, 4)

            w_bm_close:buttons(gears.table.join(
                    awful.button({}, event.mouse.button_click_left, nil,
                                 function()
                                     o.kill(o)
                                 end))
            )

            -- ICON
            ib_icon      = wibox.widget {
                widget = wibox.widget.imagebox(),
                resize = true,
            }
            w_bm_icon    = wibox.widget {
                {
                    ib_icon,
                    widget = wibox.layout.fixed.horizontal()
                },
                left   = 5, right = 5,
                top    = 5, bottom = 5,
                widget = wibox.container.margin
            }


            -- TEXT
            tb_text      = wibox.widget {
                align        = "center",
                valign       = "left",
                forced_width = 140,
                widget       = wibox.widget.textbox()
            }
            w_bm_text    = wibox.widget {
                {
                    tb_text,
                    widget = wibox.layout.fixed.horizontal()
                },
                widget = wibox.container.margin
            }


            -- WIDGET
            bg_clickable = wmapi:container()
            bg_clickable:set_widget(wibox.widget {
                w_bm_icon,
                w_bm_text,
                w_bm_close,
                widget = wibox.layout.fixed.horizontal()
            })

            bgb_item = wibox.widget({
                                        bg_clickable,
                                        widget = wibox.container.background(),
                                    })

            bgb_item:buttons(create_buttons(buttons, o))

            data[o] = {
                ib  = ib_icon,
                tb  = tb_text,
                bgb = bgb_item,
                tbm = w_bm_text,
                ibm = w_bm_icon,
                tt  = w_text
            }
        end

        local c, text, w_bg, bg_image, icon, args = label(o, tb_text)

        if text == nil or text == "" then
            tb_text:set_margins(0)
        else
            if not tb_text:set_markup_silently(text) then
                tb_text:set_markup("<i>&lt;Invalid text&gt;</i>")
            end
        end
        bgb_item:set_bg(w_bg)

        if type(bg_image) == "function" then
            -- TODO: Why does this pass nil as an argument?
            bg_image = bg_image(tb_text, o, nil, objects, i)
        end
        bgb_item:set_bgimage(bg_image)

        if icon then
            ib_icon.image = icon
        elseif c.icon then
            ib_icon.image = c.icon
        else
            -- TODO
            -- Ошибка, если иконка отсуствует
            -- то, исчезает с тасклиста апп
            ib_icon.image = resources.path .. "/error.png"
        end

        --log:debug(text, w_bg, bg_image, icon, args)

        local res = wibox.widget({
                                     {
                                         bgb_item,
                                         widget = wibox.layout.fixed.horizontal()
                                     },

                                     shape_border_width = 0.5,
                                     shape_border_color = "#00000040",
                                     shape              = function(cr, width, height)
                                         gears.shape.transform(gears.shape.rounded_rect):translate(width, 0)(cr, 0, height, 0)
                                         gears.shape.transform(gears.shape.rounded_rect):translate(0, 0)(cr, 0, height, 0)
                                     end,

                                     widget             = wibox.container.background()
                                 })

        widget:add(res)
    end
end

local function tasklist_buttons()
    return awful.util.table.join(
            awful.button(
                    { },
                    event.mouse.button_click_left,
                    function(c)
                        if c == client.focus then
                            c.minimized = true
                        else
                            c.minimized = false
                            if not c:isvisible() and c.first_tag then
                                c.first_tag:view_only()
                            end

                            client.focus = c
                            c:raise()
                        end
                    end
            )

    --wmapi:button({
    --                 event = mouse.button_click_right,
    --                 func  = function()
    --                     awful.menu.client_list({ theme = { width = 250 } })
    --                 end })
    )
end

function tasklist:init(s)
    local tasklist_template = {
        {
            {
                {
                    id     = "text_role",
                    widget = wibox.widget.textbox,
                },
                id     = "text_margin_role",
                left   = 5,
                right  = 5,
                bottom = 2,
                widget = wibox.container.margin
            },
            fill_space = true,
            layout     = wibox.layout.fixed.horizontal
        },
        id     = "background_role",
        widget = wibox.container.background
    }

    if not beautiful.tasklist_disable_icon then
        table.insert(tasklist_template[1], 1,
                     {
                         {
                             id     = "icon_role",
                             widget = wibox.widget.imagebox,
                         },
                         id     = "icon_margin_role",
                         top    = 5,
                         left   = 5,
                         widget = wibox.container.margin
                     }
        )
    end

    return w_tasklist.new {
        screen          = s,
        style           = {},
        layout          = {
            spacing = 0,
            layout  = wibox.layout.flex.horizontal()
        },
        filter          = awful.widget.tasklist.filter.currenttags,
        buttons         = tasklist_buttons(),

        widget_template = {
            {
                {
                    {
                        {
                            id     = "icon_role",
                            widget = wibox.widget.imagebox,
                        },
                        margins = 2,
                        widget  = wibox.container.margin,
                    },
                    {
                        id     = "text_role",
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left   = 10,
                right  = 10,
                widget = wibox.container.margin
            },
            id     = "background_role",
            widget = wibox.container.background,
        },

        update_function = update_function,
    }

    -- @TASKLIST_BUTTON@
    -- Create a tasklist widget
    --s.mytasklist = awful.widget.tasklist {
    --    screen          = s,
    --    filter          = awful.widget.tasklist.filter.currenttags,
    --    buttons         = {
    --        awful.button({ }, 1, function(c)
    --            c:activate { context = "tasklist", action = "toggle_minimization" }
    --        end),
    --        awful.button({ }, 3, function()
    --            awful.menu.client_list { theme = { width = 250 } }
    --        end),
    --        awful.button({ }, 4, function()
    --            awful.client.focus.byidx(-1)
    --        end),
    --        awful.button({ }, 5, function()
    --            awful.client.focus.byidx(1)
    --        end),
    --    },
    --    style           = {
    --        shape_border_width = 1,
    --        shape_border_color = '#777777',
    --        shape              = gears.shape.rounded_bar,
    --    },
    --    layout          = {
    --        spacing        = 10,
    --        spacing_widget = {
    --            {
    --                forced_width = 5,
    --                shape        = gears.shape.circle,
    --                widget       = wibox.widget.separator
    --            },
    --            valign = 'center',
    --            halign = 'center',
    --            widget = wibox.container.place,
    --        },
    --        layout         = wibox.layout.flex.horizontal
    --    },
    --    widget_template = {
    --        {
    --            {
    --                {
    --                    {
    --                        id     = 'icon_role',
    --                        widget = wibox.widget.imagebox,
    --                    },
    --                    margins = 2,
    --                    widget  = wibox.container.margin,
    --                },
    --                {
    --                    id     = 'text_role',
    --                    widget = wibox.widget.textbox,
    --                },
    --                layout = wibox.layout.fixed.horizontal,
    --            },
    --            left   = 10,
    --            right  = 10,
    --            widget = wibox.container.margin
    --        },
    --        id     = 'background_role',
    --        widget = wibox.container.background,
    --    },
    --}

end

return setmetatable(tasklist, { __call = function(_, ...)
    return tasklist:init(...)
end })
