local widget       = require("util.widgets")
local gtable       = require("lib.gears.table")
local awful        = require("lib.awful")
local beautiful    = require("lib.beautiful")
local wibox        = require("lib.wibox")
local gtable       = require("lib.gears.table")
local helpers      = require("helpers")
local change_theme = require("widgets.button_change_theme")

-- beautiful var
local wibar_pos    = beautiful.wibar_position or "top"

local layout_root  = class()

function layout_root:init(args)
    -- options
    self.mode               = args.mode or "icons" -- possible value: icons , menu
    self.icon_startscreen   = { " ", beautiful.fg_grey_light }
    self.icon_monitor       = { " ", beautiful.fg_grey_light }
    self.icon_lockscreen    = { " ", beautiful.fg_grey_light }
    self.icon_menu          = self:choose_icon_menu()
    -- widgets
    self.monitoring_button  = widget.create_button(self.icon_monitor[2], self.icon_monitor[1])
    self.startscreen_button = widget.create_button(self.icon_startscreen[2], self.icon_startscreen[1])
    self.lockscreen_button  = widget.create_button(self.icon_lockscreen[2], self.icon_lockscreen[1])
    self.widget             = self:make_widget()
end

function layout_root:make_widget()
    if self.mode == "menu" then
        return self:make_menu()
    else
        return self:make_icons()
    end
end

local function fixed_position(want)
    if wibar_pos == "top" or wibar_pos == "bottom" then
        return want == 'string' and "horizontal" or wibox.layout.fixed.horizontal
    else
        return want == 'string' and "vertical" or wibox.layout.fixed.vertical
    end
end

function layout_root:choose_icon_menu()
    local icon
    local wibar_position = beautiful.wibar_position or "top"
    if wibar_position == "top" then
        icon = ""
    elseif wibar_position == "bottom" then
        icon = ""
    elseif wibar_position == "left" then
        icon = ""
    elseif wibar_position == "right" then
        icon = ""
    end
    return icon
end

function layout_root:create_popup(w)
    local popup = awful.popup {
        widget              = {
            {
                nil,
                {
                    self:make_icons(),
                    change_theme,
                    spacing = beautiful.widget_spacing or 10,
                    layout  = wibox.layout.fixed.horizontal
                },
                nil,
                layout = wibox.layout.align.horizontal,
            },
            margins = 10,
            widget  = wibox.container.margin
        },
        visible             = false,
        ontop               = true,
        hide_on_right_click = true,
        shape               = helpers.rrect(10)
    }
    popup:bind_to_widget(w)
    w:buttons(gtable.join(
            awful.button({}, 3, function()
                popup.visible = false
            end)
    ))
end

function layout_root:create_buttons()

    self.monitoring_button:buttons(gtable.join(
            awful.button({}, 1, function()
                local curr_screen               = awful.screen.focused()
                curr_screen.monitor_bar.visible = not curr_screen.monitor_bar.visible
            end)
    ))

    self.startscreen_button:buttons(gtable.join(
            awful.button({}, 1, function()
                start_screen.visible = not start_screen.visible
            end)
    ))

    self.lockscreen_button:buttons(gtable.join(
            awful.button({}, 1, function()
                lock_screen_show()
            end)
    ))

    local function set_tooltip(w, text)
        local tooltip = awful.tooltip({ objects = { w } })
        w:connect_signal('mouse::enter', function()
            tooltip.text = text
        end)
    end

    set_tooltip(self.monitoring_button, 'Show/Hide monitor bar')
    set_tooltip(self.startscreen_button, 'Show/Hide start_screen')
    set_tooltip(self.lockscreen_button, 'Lock screen')
end

local function add_margin()
    local c = wibox.container.margin()
    if wibar_pos == 'top' or wibar_pos == 'bottom' then
        c.top    = 3
        c.bottom = 3
    else
        c.left  = 6
        c.right = 6
    end
    return c
end

function layout_root:make_icons()
    self:create_buttons()
    local w = wibox.widget {
        {
            self.lockscreen_button,
            self.monitoring_button,
            self.startscreen_button,
            spacing = beautiful.widget_spacing or 1,
            layout  = fixed_position(ob)
        },
        widget = add_margin()
    }
    return w
end

function layout_root:make_menu()
    local wicon = widget.create_button(beautiful.fg_grey, self.icon_menu)
    self:create_popup(wicon)
    local w = wibox.widget {
        wicon,
        layout = wibox.layout.fixed.horizontal
    }
    return w
end

-- herit
local layout_widget = class(layout_root)

function layout_widget:init(args)
    layout_root.init(self, args)
    return self.widget
end

return layout_widget
