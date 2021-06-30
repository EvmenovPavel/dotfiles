local awful                      = require("awful")
local wibox                      = require("wibox")
local gears                      = require("gears")
local beautiful                  = require("beautiful")
local dpi                        = require("beautiful").xresources.apply_dpi
local signals                    = require("components.signals")

local PATH_TO_ICONS              = os.getenv("HOME") .. "/.config/awesome/icons/notification/"

local panel_shape                = function(cr, width, height)
    gears.shape.partially_rounded_rect(cr, width, height, false, true, true, false, 0)
end
local maximized_panel_shape      = function(cr, width, height)
    gears.shape.rectangle(cr, width, height)
end

local widget_icon                = wibox.widget {
    {
        id     = "icon",
        image  = PATH_TO_ICONS .. "notification.svg",
        widget = wibox.widget.imagebox,
        resize = true
    },
    layout = wibox.layout.align.horizontal
}

local widget_button              = capi.wmapi:container(wibox.container.margin(widget_icon, dpi(7), dpi(7), dpi(7), dpi(7)))

widget_button.panel_notification = awful.wibar({
                                                   visible  = false,
                                                   position = "right",
                                                   workarea = false,
                                                   width    = 400,
                                                   ontop    = true,
                                                   shape    = maximized_panel_shape,
                                               })

local function append_widget_notify(args)
    --markup, image
    local args        = args or {}

    local title       = args.title or "Title: test111"
    local text        = args.text or "Text: test111"
    local icon        = args.icon or "/home/be3yh4uk/.config/awesome/icons/close.svg"
    local bg          = args.bg or "#001133"

    local w_title     = wibox.widget({
                                         {
                                             font   = beautiful.font,

                                             widget = wibox.widget.textbox,
                                             markup = title,

                                             align  = "left",
                                             valign = "center",
                                         },
                                         widget = wibox.container.background,
                                     })

    local w_text      = wibox.widget({
                                         {
                                             font   = beautiful.font,

                                             widget = wibox.widget.textbox,
                                             markup = text,

                                             align  = "left",
                                             valign = "center",
                                         },
                                         widget = wibox.container.background,
                                     })

    local w_icon_app  = wibox.widget({
                                         {
                                             widget        = wibox.widget.imagebox,
                                             image         = icon,
                                             resize        = true,

                                             align         = "center",
                                             valign        = "center",

                                             forced_height = 24,
                                             forced_width  = 24,
                                         },
                                         widget = wibox.container.background
                                     })

    local w_close_app = wibox.widget({
                                         {
                                             widget        = wibox.widget.imagebox,
                                             image         = icon,
                                             --resize        = true,

                                             align         = "center",
                                             valign        = "center",

                                             forced_height = 12,
                                             forced_width  = 12,
                                         },
                                         widget = wibox.container.background
                                     })

    local w_date      = wibox.widget({
                                         {
                                             font   = beautiful.font,

                                             widget = wibox.widget.textbox,
                                             markup = tostring(os.date()),

                                             align  = "left",
                                             valign = "center",
                                         },
                                         widget = wibox.container.background,
                                     })

    local item        = wibox.widget({
                                         {
                                             {
                                                 {
                                                     w_icon_app,
                                                     margins = 10,
                                                     widget  = wibox.container.margin
                                                 },
                                                 {
                                                     {
                                                         {
                                                             top    = 10,
                                                             w_title,
                                                             --margins = 2,
                                                             widget = wibox.container.margin
                                                         },
                                                         {
                                                             w_close_app,
                                                             margins = 10,
                                                             widget  = wibox.container.margin
                                                         },

                                                         --expand = "none",
                                                         layout = wibox.layout.align.horizontal,
                                                     },
                                                     {
                                                         w_text,
                                                         top    = 5,
                                                         bottom = 5,
                                                         right  = 10,
                                                         --margins = 2,
                                                         widget = wibox.container.margin,
                                                     },
                                                     {
                                                         w_date,
                                                         bottom = 10,
                                                         --margins = 2,
                                                         widget = wibox.container.margin,
                                                     },
                                                     widget = wibox.layout.fixed.vertical,
                                                 },
                                                 widget = wibox.layout.fixed.horizontal,
                                             },

                                             bg         = bg,
                                             shape      = gears.shape.rounded_rect,
                                             shape_clip = true,
                                             widget     = wibox.container.background,
                                         },
                                         --color  = "#001100",
                                         bottom = 5,
                                         widget = wibox.container.margin,
                                     })

    item:connect_signal(signals.button.release,
                        function()
                            --textbox.bg  = colorClick
                            --imagebox.bg = colorClick
                            --awful.util.spawn(command)
                            --quitmenu_widget.show()
                        end)
    item:connect_signal(signals.mouse.enter,
                        function()
                            -- show
                            --textbox.bg  = colorShow
                            --imagebox.bg = colorShow
                        end)
    item:connect_signal(signals.mouse.leave,
                        function()
                            -- hide
                            --textbox.bg  = colorHide
                            --imagebox.bg = colorHide
                        end)

    return item
end

-- Layout
local notifbox_layout = wibox.layout.fixed.vertical()

function widget_button:append(args)
    notifbox_layout:insert(1, append_widget_notify(args))
end



--t = wibox.widget.textbox('Some text witch need to be justified')
--notifbox_layout._private.layout:set_justify(true)
--notifbox_layout:emit_signal("widget::redraw_needed")
--notifbox_layout:emit_signal("widget::layout_changed")


widget_button.panel_notification:setup {
    {
        notifbox_layout,
        widget = wibox.layout.align.vertical
        --layout = wibox.container.scroll.vertical,
    },
    margins = 10,
    widget  = wibox.container.margin,
}


--widget_button.panel_notification

local own_widget         = wibox.widget.base.make_widget()
local offset_x, offset_y = -20, 0
--function own_widget:layout(context, width, height)
--    -- No idea how to pick good widths and heights for the inner widget.
--    return { wibox.widget.base.place_widget_at(my_widget(), offset_x, offset_y, 200, 40) }
--end

widget_button:buttons(
        gears.table.join(
                awful.button({}, 1, nil,
                             function()
                                 widget_button.panel_notification.visible = not widget_button.panel_notification.visible
                             end
                )
        )
)

return widget_button
