local awful   = require("awful")
local wibox   = require("wibox")
local dpi     = require("beautiful").xresources.apply_dpi
local key     = require("event").key
local mouse   = require("event").mouse

local taglist = {}

function taglist:button()
    return awful.util.table.join(
            awful.button({}, mouse.button_click_left,
                         function(c)
                             c:view_only()
                         end
            ),
            awful.button({ key.mod }, mouse.button_click_left,
                         function(c)
                             if capi.client.focus then
                                 capi.client.focus:move_to_tag(c)
                                 c:view_only()
                             end
                         end
            ),

            awful.button({}, mouse.button_click_right,
                         awful.tag.viewtoggle
            ),

            awful.button({ key.mod }, mouse.button_click_right,
                         function(c)
                             if capi.client.focus then
                                 capi.client.focus:toggle_tag(c)
                             end
                         end
            )
    )
end

function list_update(w, buttons, label, data, objects)
    w:reset()
    for i, o in ipairs(objects) do
        local cache = data[o]
        local ib, tb, bgb, tbm, ibm, l, bg_clickable
        if cache then
            ib  = cache.ib
            tb  = cache.tb
            bgb = cache.bgb
            tbm = cache.tbm
            ibm = cache.ibm
        else
            local icondpi = 3
            ib            = wibox.widget.imagebox()
            tb            = wibox.widget.textbox()
            bgb           = wibox.container.background()
            tbm           = wibox.container.margin(tb, dpi(4), dpi(16))
            ibm           = wibox.container.margin(ib, dpi(icondpi), dpi(icondpi), dpi(icondpi), dpi(icondpi))
            l             = wibox.layout.fixed.horizontal()
            bg_clickable  = capi.wmapi:container()

            l:fill_space(true)
            l:add(ibm)
            bg_clickable:set_widget(l)

            bgb:set_widget(bg_clickable)

            --bgb:buttons(create_buttons(buttons, o))

            data[o] = {
                ib  = ib,
                tb  = tb,
                bgb = bgb,
                tbm = tbm,
                ibm = ibm
            }
        end

        local text, bg, bg_image, icon, args = label(o, tb)
        args                                 = args or {}

        bgb:set_bg(bg)
        if type(bg_image) == "function" then
            -- TODO: Why does this pass nil as an argument?
            bg_image = bg_image(tb, o, nil, objects, i)
        end

        bgb:set_bgimage(bg_image)
        if icon then
            ib.image = icon
        else
            ibm:set_margins(0)
        end

        bgb.shape              = args.shape
        bgb.shape_border_width = args.shape_border_width
        bgb.shape_border_color = args.shape_border_color

        w:add(bgb)
    end
end

function taglist:create(s)
    return awful.widget.taglist {
        screen          = s,
        filter          = awful.widget.taglist.filter.all,
        style           = {
            --taglist_count          = 10,
            --taglist_spacing        = 10,
            --taglist_squares_resize = true,

            spacing = 0,
            --taglist_spacing = ,

            --shape_border_width = 1,
            --shape_border_color = "#ffffff20",
            --shape              = function(cr, width, height)
            --    gears.shape.transform(gears.shape.rounded_rect):translate(width, 0)(cr, 0, height, 0)
            --end,

            --update_function = list_update,
            --shape = gears.shape.powerline
        },
        buttons         = self:button(),
        widget_template = {
            {
                {
                    id     = 'icon_role',
                    widget = wibox.widget.imagebox,
                },
                {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            id              = 'background_role',
            widget          = wibox.container.background,

            create_callback = function(self, c3, index, objects)
                local old_cursor, old_wibox

                self:connect_signal(
                        "mouse::enter",
                        function()
                            self.bg = "#ffffff11"
                            local w = _G.mouse.current_wibox
                            if w then
                                old_cursor, old_wibox = w.cursor, w
                                w.cursor              = "hand1"
                            end
                        end
                )

                self:connect_signal(
                        "mouse::leave",
                        function()
                            self.bg = "#ffffff00"
                            if old_wibox then
                                old_wibox.cursor = old_cursor
                                old_wibox        = nil
                            end
                        end
                )

                self:connect_signal(
                        "button::press",
                        function()
                            self.bg = "#ffffff22"
                        end
                )

                self:connect_signal(
                        "button::release",
                        function()
                            self.bg = "#ffffff11"
                        end
                )
            end,
        },

        update_callback = list_update,
    }
end

--return taglist
return setmetatable(taglist, {
    __call = taglist.create,
})