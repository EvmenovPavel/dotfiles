local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local resources = require("resources")

local tasklist  = {}

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
            -- CLOSE
            w_bm_close = capi.wmapi:container()
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
                    awful.button({}, capi.event.mouse.button_click_left, nil,
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
            bg_clickable = capi.wmapi:container()
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

        local text, w_bg, bg_image, icon, args = label(o, tb_text)

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
        else
            -- TODO
            -- Ошибка, если иконка отсуствует
            -- то, исчезает с тасклиста апп
            -- ib_icon:set_margins(0)
            ib_icon.image = resources.error
        end

        local res = wibox.widget({
                                     {
                                         bgb_item,
                                         widget = wibox.layout.fixed.horizontal()
                                     },

                                     shape_border_width = 0.5,
                                     shape_border_color = "#ffffff20",
                                     shape              = function(cr, width, height)
                                         gears.shape.transform(gears.shape.rounded_rect):translate(width, 0)(cr, 0, height, 0)
                                         gears.shape.transform(gears.shape.rounded_rect):translate(0, 0)(cr, 0, height, 0)
                                     end,

                                     widget             = wibox.container.background()
                                 })

        widget:add(res)
    end
end

function tasklist:tasklist_buttons()
    return awful.util.table.join(
            capi.wmapi:button({
                                  event = capi.event.mouse.button_click_left,
                                  func  = function(c)
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
                                  end }),

            capi.wmapi:button({
                                  event = capi.event.mouse.button_click_right,
                                  func  = function()
                                      awful.menu.client_list({ theme = { width = 250 } })
                                  end })
    )
end

function tasklist:init(s)
    return awful.widget.tasklist {
        screen          = s,
        style           = {},
        layout          = {
            spacing = 0,
            layout  = wibox.layout.flex.horizontal()
        },
        filter          = awful.widget.tasklist.filter.currenttags,
        buttons         = self:tasklist_buttons(),

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

        update_function = list_update,
    }
end

return setmetatable(tasklist, { __call = function(_, ...)
    return tasklist:init(...)
end })
