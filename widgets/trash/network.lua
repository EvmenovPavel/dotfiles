local beautiful    = require("lib.beautiful")
local dpi          = beautiful.xresources.apply_dpi
local widget       = require("util.widgets")
local helpers      = require("helpers")
local wibox        = require("lib.wibox")

-- beautiful vars
local fg           = beautiful.widget_network_fg
local spacing      = beautiful.widget_spacing or 1

-- root
local network_root = class()

function network_root:init(args)
    -- options
    self.icon_up     = args.icon_up or beautiful.widget_network_icon_up or { "ﲗ", beautiful.fg_grey }
    self.icon_down   = args.icon_down or beautiful.widget_network_icon_down or { "ﲐ", beautiful.fg_grey }
    self.icon_ip     = args.icon_ip or beautiful.widget_network_icon_ip or { "", beautiful.fg_grey }
    self.title       = args.title or beautiful.widget_network_title or { "NET", beautiful.fg_grey }
    self.title_size  = args.title_size or 10
    self.mode        = args.mode or 'text' -- possible values: ip, text
    self.want_layout = args.layout or beautiful.widget_network_layout or 'horizontal' -- possible values: horizontal , vertical
    self.bar_size    = args.bar_size or 100
    self.bar_colors  = args.bar_colors or beautiful.bar_colors or { beautiful.primary, beautiful.alert }
    -- base widgets
    self.wicon_up    = widget.base_icon(self.icon_up[1], self.icon_up[2])
    self.wicon_down  = widget.base_icon(self.icon_down[1], self.icon_down[2])
    self.wicon_net   = widget.base_icon(self.icon_ip[1], self.icon_ip[2])
    self.wtext       = widget.base_text()
    self.wtext_1     = widget.base_text()
    self.wtext_2     = widget.base_text()
    self.wtitle      = widget.create_title(self.title[1], self.title[2], self.title_size)
    self.widget      = self:make_widget()
end

function network_root:make_widget()
    if self.mode == "ip" then
        return self:make_ip()
    elseif self.mode == "block" then
        return self:make_block()
    else
        return self:make_text()
    end
end

function network_root:make_ip()
    local w = widget.box_with_margin(self.want_layout, { self.wicon_net, self.wtext_1 }, spacing)
    awesome.connect_signal("daemon::network", function(net)
        self.wtext_1.markup = helpers.colorize_text(net[env.net_device].name .. " " .. net[env.net_device].ip, fg)
    end)
    return w
end

function network_root:make_text()
    local w = widget.box_with_margin(self.want_layout, { self.wicon_up, self.wtext_1, self.wicon_down, self.wtext_2 }, spacing)
    awesome.connect_signal("daemon::network", function(net)
        self.wtext_1.markup = helpers.colorize_text(net[env.net_device].up, fg)
        self.wtext_2.markup = helpers.colorize_text(net[env.net_device].down, fg)
    end)
    return w
end

function network_root:make_progressbar_vert(p_up, p_down)
    local w = wibox.widget {
        {
            nil,
            widget.box('vertical', { self.wtitle, self.wtext }),
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        {
            nil,
            {
                widget.box('vertical', { p_up, self.wicon_up }),
                widget.box('vertical', { p_down, self.wicon_down }),
                spacing = 2,
                layout  = wibox.layout.fixed.horizontal
            },
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        spacing = 15,
        layout  = wibox.layout.fixed.horizontal
    }
    return w
end

function network_root:make_block()
    local pu     = widget.make_progressbar(_, self.bar_size, { self.bar_colors[1][1], self.bar_colors[2] })
    pu.max_value = 80000
    local pd     = widget.make_progressbar(_, self.bar_size, { self.bar_colors[1][2], self.bar_colors[2] })
    pd.max_value = 80000
    local w
    local ip     = widget.base_text()
    if self.want_layout == 'horizontal' then
        local space = 8
        w           = wibox.widget {
            {
                widget.box(self.want_layout, { self.wicon_net, ip }, space),
                widget = widget.progressbar_margin_horiz()
            },
            {
                widget.box(self.want_layout, { self.wicon_up, pu, self.wtext_1 }, space),
                widget = widget.progressbar_margin_horiz()
            },
            {
                widget.box(self.want_layout, { self.wicon_down, pd, self.wtext_2 }, space),
                widget = widget.progressbar_margin_horiz()
            },
            layout = wibox.layout.fixed.vertical
        }
    elseif self.want_layout == 'vertical' then
        local p_up   = widget.progressbar_layout(pu, self.want_layout)
        local p_down = widget.progressbar_layout(pd, self.want_layout)
        w            = self:make_progressbar_vert(p_up, p_down)
    end
    awesome.connect_signal("daemon::network", function(net)
        if not net[env.net_device] then
            return
        end
        local up            = net[env.net_device].up
        local down          = net[env.net_device].down
        pu.value            = up
        pd.value            = down
        ip.markup           = helpers.colorize_text(net[env.net_device].ip, fg)
        self.wtext_1.markup = helpers.colorize_text(up .. " B/s", fg)
        self.wtext_2.markup = helpers.colorize_text(down .. " B/s", fg)
        self.wtext.markup   = helpers.colorize_text(env.net_device, fg)
    end)
    return w
end

-- herit
local network_widget = class(network_root)

function network_widget:init(args)
    network_root.init(self, args)
    return self.widget
end

return network_widget
