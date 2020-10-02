local awful    = require("awful")
local wibox    = require("wibox")
local gears    = require("gears")
local mouse    = require("event").mouse

local dpi      = require("beautiful").xresources.apply_dpi
local ICON_DIR = gears.filesystem.get_configuration_dir() .. "/icons/"

-- define module table
local tasklist = {}

local shape    = {
    function(cr, width, height)
        gears.shape.transform(gears.shape.rounded_rect):translate(0, height - 1)(cr, width, 1, 0)
    end,

    function(cr, width, height)
        local top    = 0
        local left   = 0
        local radial = 5

        gears.shape.transform(gears.shape.rounded_rect):translate(left, top)(cr, width, height, radial)
    end
}

local function create_buttons(buttons, object)
    if buttons then
        local btns = {}
        for _, b in ipairs(buttons) do
            -- Create a proxy button object: it will receive the real
            -- press and release events, and will propagate them to the
            -- button object the user provided, but with the object as
            -- argument.
            local btn = capi.button { modifiers = b.modifiers, button = b.button }
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

local function list_update(widget, buttons, label, data, objects)
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
            w_bm_close = capi.wmapi:container()
            w_bm_close:set_widget(wibox.widget {
                {
                    widget = wibox.widget.imagebox,
                    image  = ICON_DIR .. "close.svg",
                    resize = true,
                },
                margins = 6,
                widget  = wibox.container.margin,
            })
            w_bm_close.shape = gears.shape.circle
            w_bm_close       = wibox.container.margin(w_bm_close, dpi(4), dpi(4), dpi(4), dpi(4))
            w_bm_close:buttons(gears.table.join(
                    awful.button({}, mouse.button_click_left, nil,
                                 function()
                                     o.kill(o)
                                 end))
            )

            ib_icon      = wibox.widget {
                widget = wibox.widget.imagebox(),
                resize = true,
            }
            w_bm_icon    = wibox.container.margin(ib_icon, dpi(6), dpi(6), dpi(6), dpi(6))

            tb_text      = wibox.widget {
                align        = "center",
                valign       = "left",
                forced_width = 140,
                widget       = wibox.widget.textbox()
            }
            w_bm_text    = wibox.container.margin(tb_text, dpi(4), dpi(4))

            bg_clickable = capi.wmapi:container()
            bg_clickable:set_widget(wibox.widget {
                w_bm_icon,
                --spacing = beautiful.tasklist_spacing,
                w_bm_text,
                --spacing = beautiful.tasklist_spacing,
                w_bm_close,
                widget = wibox.layout.fixed.horizontal()
            })

            bgb_item = wibox.widget({
                                        bg_clickable,
                                        widget = wibox.container.background(),
                                    })

            bgb_item:buttons(create_buttons(buttons, o))

            -- Tooltip to display whole title, if it was truncated
            w_text  = awful.tooltip({
                                        objects    = { tb_text },
                                        mode       = "outside",
                                        align      = "bottom",
                                        delay_show = 1,
                                    })

            data[o] = {
                ib  = ib_icon,
                tb  = tb_text,
                bgb = bgb_item,
                tbm = w_bm_text,
                ibm = w_bm_icon,
                tt  = w_text
            }
        end

        local text, w_bg, bg_image, icon, args = label(o, tb_text)
        --local args                             = args or {}

        ---- The text might be invalid, so use pcall.
        if text == nil or text == "" then
            w_bm_text:set_margins(0)
        else
            -- truncate when title is too long
            --log:message()

            local text_only = text:match(">(.-)<")
            if (text_only:len() > 10) then
                text = text:gsub(">(.-)<", ">" .. text_only:sub(1, 19) .. "...<")
                w_text:set_text(text_only)
                w_text:add_to_object(tb_text)
            else
                w_text:remove_from_object(tb_text)
            end
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
        else
            w_bm_icon:set_margins(0)
        end

        --bgb_item.shape              = shape[1]--args.shape
        --bgb_item.shape_border_width = args.shape_border_width
        --bgb_item.shape_border_color = args.shape_border_color

        widget:add(bgb_item)
    end
end

local buttons = awful.util.table.join(
        awful.button({}, mouse.button_click_left,
                     function(c)
                         if c == capi.client.focus then
                             c.minimized = true
                         else
                             c.minimized = false
                             if not c:isvisible() and c.first_tag then
                                 c.first_tag:view_only()
                             end

                             capi.client.focus = c
                             c:raise()
                         end
                     end),

        awful.button({}, mouse.button_click_right,
                     function()
                         awful.menu.client_list({ theme = { width = 250 } })
                     end)
)

function tasklist:create(s)
    return awful.widget.tasklist(
            s,
            awful.widget.tasklist.filter.currenttags,
            buttons,
            {},
            list_update,
            wibox.layout.fixed.horizontal()
    )
end

return setmetatable(tasklist, {
    __call = tasklist.create,
})