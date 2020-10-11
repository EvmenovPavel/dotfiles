local wibox        = require("lib.wibox")
local beautiful    = require("lib.beautiful")
local widget       = require("util.widgets")
local helpers      = require("helpers")

-- beautiful vars
local fg           = beautiful.widget_battery_fg
local spacing      = beautiful.widget_spacing or 1

-- root
local battery_root = class()

function battery_root:init(args)
    -- options
    self.icon        = args.icon or beautiful.widget_battery_icon or { "臘", beautiful.fg_grey }
    self.title       = args.title or beautiful.widget_battery_title or { "BAT", beautiful.fg_grey }
    self.title_size  = args.title_size or 10
    self.mode        = args.mode or 'text' -- possible values: text, progressbar, slider
    self.want_layout = args.layout or beautiful.widget_battery_layout or 'horizontal' -- possible values: horizontal , vertical
    self.bar_size    = args.bar_size or 200
    self.bar_colors  = args.bar_colors or beautiful.bar_colors or { beautiful.primary, beautiful.alert }
    -- base widgets
    self.wicon       = widget.base_icon(self.icon[1], self.icon[2])
    self.wtitle      = widget.create_title(self.title[1], self.title[2], self.title_size)
    self.wtext       = widget.base_text()
    self.widget      = self:make_widget()
end

function battery_root:make_widget()
    if self.mode == "progressbar" then
        return self:make_progressbar()
    else
        return self:make_text()
    end
end

function battery_root:make_text()
    local w = widget.box_with_margin(self.want_layout,
                                     {
                                         self.wicon,
                                         self.wtext
                                     }, spacing)
    awesome.connect_signal("daemon::battery", function(state, percent)
        self.wicon.markup = helpers.colorize_text(state[1], state[2])
        self.wtext.markup = helpers.colorize_text(percent .. '%', fg)
    end)
    return w
end

function battery_root:make_progressbar_vert(p)
    local w = wibox.widget {
        {
            nil,
            widget.box('vertical', { self.wtitle, self.wtext }),
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        {
            nil,
            widget.box('vertical', { p, self.wicon }),
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        spacing = 15,
        layout  = wibox.layout.fixed.horizontal
    }
    return w
end

function battery_root:make_progressbar()
    local p  = widget.make_progressbar(_, self.bar_size, { self.bar_colors[1][1], self.bar_colors[2] })
    local wp = widget.progressbar_layout(p, self.want_layout)
    local w
    if self.want_layout == 'vertical' then
        w = self:make_progressbar_vert(wp)
    else
        w = widget.box_with_margin(self.want_layout, { self.wicon, wp }, 8)
    end
    awesome.connect_signal("daemon::battery", function(state, percent)
        p.value           = percent
        self.wtext.markup = helpers.colorize_text(env.battery, beautiful.fg_grey)
    end)
    return w
end

-- herit
local battery_widget = class(battery_root)

function battery_widget:init(args)
    battery_root.init(self, args)
    return self.widget
end

return battery_widget
