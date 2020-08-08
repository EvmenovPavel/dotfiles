local gtable              = require("lib.gears.table")
local beautiful           = require("lib.beautiful")
local awful               = require("lib.awful")
local wibox               = require("lib.wibox")
local gears               = require("lib.gears")
local clickable_container = require("widgets.clickable-container")

local mouse               = require("device.mouse")

local dpi                 = require("lib.beautiful").xresources.apply_dpi
local capi                = { button = button }
local ICON_DIR            = gears.filesystem.get_configuration_dir() .. "/icons/"

-- define module table
local task_list           = {}


-- ===================================================================
-- Functionality
-- ===================================================================


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
            w_bm_close = clickable_container()
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
            w_bm_close:buttons(gears.table.join(awful.button({}, 1, nil,
                                                             function()
                                                                 o.kill(o)
                                                             end
            )))

            ib_icon      = wibox.widget {
                widget = wibox.widget.imagebox(),
                resize = true,
            }
            w_bm_icon    = wibox.container.margin(ib_icon, dpi(6), dpi(6), dpi(6), dpi(6))

            tb_text      = wibox.widget {
                --markup = 'This <i>is</i> a <b>textbox</b>!!!',
                align        = "center",
                valign       = "left",
                forced_width = 140,
                widget       = wibox.widget.textbox()
            }
            w_bm_text    = wibox.container.margin(tb_text, dpi(4), dpi(4))

            bg_clickable = clickable_container()
            bg_clickable:set_widget(wibox.widget {
                w_bm_icon,
                w_bm_text,
                w_bm_close,
                widget = wibox.layout.fixed.horizontal()
            })

            bgb_item = wibox.widget({
                                        bg_clickable,
                                        forced_width = 210,
                                        widget       = wibox.container.background(),
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
        local args                             = args or {}

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

        bgb_item.shape              = args.shape
        bgb_item.shape_border_width = args.shape_border_width
        bgb_item.shape_border_color = args.shape_border_color

        widget:add(bgb_item)
    end
end

local tasklist_buttons = awful.util.table.join(
        awful.button({}, 1,
                     function(c)
                         if c == client.focus then
                             c.minimized = true
                         else
                             -- Without this, the following
                             -- :isvisible() makes no sense
                             c.minimized = false
                             if not c:isvisible() and c.first_tag then
                                 c.first_tag:view_only()
                             end
                             -- This will also un-minimize
                             -- the client, if needed
                             client.focus = c
                             c:raise()
                         end
                     end
        ),
        awful.button({}, 2,
                     function(c)
                         c.kill(c)
                     end
        )
)

task_list.create       = function(s)
    return awful.widget.tasklist(
            s,
            awful.widget.tasklist.filter.currenttags,
            tasklist_buttons,
            {},
            list_update,
            wibox.layout.fixed.horizontal()
    )
end

return task_list
