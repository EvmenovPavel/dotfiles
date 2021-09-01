local awful   = require("awful")
local wibox   = require("wibox")
local dpi     = require("beautiful").xresources.apply_dpi
local key     = capi.wmapi.event.key
local mouse   = capi.wmapi.event.mouse

local taglist = {}

function create_callback(self, c3, index, objects)
    local old_cursor, old_wibox

    --mouse::enter
    --mouse::leave
    --mouse::press
    --mouse::release
    --mouse::move

    self:connect_signal(
            "mouse::enter",
            function()
                local w = _G.mouse.current_wibox
                if w then
                    old_cursor, old_wibox = w.cursor, w
                    w.cursor              = "hand1"
                else
                    self.bg = "#ffffff11"
                end
            end
    )

    -- TODO
    -- ошибка принаведении курсором на тег
    self:connect_signal(
            "mouse::leave",
            function()
                if old_wibox then
                    old_wibox.cursor = old_cursor
                    old_wibox        = nil
                else
                    self.bg = "#ffffff00"
                end
            end
    )

    --self:connect_signal(
    --        "button::press",
    --        function()
    --            self.bg = "#ffffff22"
    --        end
    --)

    --self:connect_signal(
    --        "button::release",
    --        function()
    --            self.bg = "#ffffff11"
    --        end
    --)
end

function update_callback(w, buttons, label, data, objects)
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

function buttons()
    return awful.util.table.join(
            capi.wmapi:button({
                                  event = mouse.button_click_left,
                                  func  = function(c)
                                      c:view_only()
                                  end
                              }),

            capi.wmapi:button({
                                  key   = key.mod,
                                  event = mouse.button_click_left,
                                  func  = function(c)
                                      if capi.client.focus then
                                          capi.client.focus:move_to_tag(c)
                                          c:view_only()
                                      end
                                  end
                              }),

            capi.wmapi:button({
                                  event = mouse.button_click_right,
                                  func  = awful.tag.viewtoggle
                              }),

            capi.wmapi:button({
                                  key   = key.mod,
                                  event = mouse.button_click_right,
                                  func  = function(c)
                                      if capi.client.focus then
                                          capi.client.focus:toggle_tag(c)
                                      end
                                  end
                              })
    )
end

function widget_template()
    return {
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

        create_callback = create_callback
    }
end

function taglist:init(s)
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

        widget_template = widget_template(),
        buttons         = buttons(),
        update_callback = update_callback,
    }
end

return setmetatable(taglist, { __call = function(_, ...)
    return taglist:init(...)
end })
