local beautiful   = require("lib.beautiful")
local widget      = require("util.widgets")
local helpers     = require("helpers")
local wibox       = require("lib.wibox")
local aspawn      = require("lib.awful.spawn")

-- beautiful vars
local fg          = beautiful.widget_volume_fg
local fg_err      = beautiful.fg_alert or '#882233'
local spacing     = beautiful.widget_spacing or 1

-- root
local volume_root = class()

function volume_root:init(args)
    -- options
    self.icon        = args.icon or beautiful.widget_volume_icon or { "", beautiful.fg_grey }
    self.mode        = args.mode or 'text' -- possible values: text, progressbar, slider
    self.want_layout = args.layout or beautiful.widget_volume_layout or 'horizontal' -- possible values: horizontal , vertical
    self.bar_size    = args.bar_size or 200
    self.bar_colors  = args.bar_colors or beautiful.bar_colors or { beautiful.primary, beautiful.alert }
    self.title       = args.title or beautiful.widget_volume_title or { "VOL", beautiful.fg_grey }
    self.title_size  = args.title_size or 10
    -- base widgets
    self.wicon       = widget.base_icon(self.icon[1], self.icon[2])
    self.wtitle      = widget.create_title(self.title[1], self.title[2], self.title_size)
    self.wtext       = widget.base_text()
    self.widget      = self:make_widget()
end

function volume_root:make_widget()
    if self.mode == "progressbar" then
        return self:make_progressbar()
    elseif self.mode == "slider" then
        return self:make_slider()
    else
        return self:make_text()
    end
end

function volume_root:update(volume, fg)
    self.wtext.markup = helpers.colorize_text(volume .. "%", fg)
end

function volume_root:make_text()
    local w = widget.box_with_margin(self.want_layout, { self.wicon, self.wtext }, spacing)
    awesome.connect_signal("daemon::volume", function(volume, is_muted)
        if is_muted then
            self:update(volume, fg_err)
        else
            self:update(volume, fg)
        end
    end)
    return w
end

function volume_root:make_slider()
    local volume = widget.make_a_slider(15)
    local w      = widget.add_icon_to_slider(volume, self.icon[1], self.icon[2], 'horizontal')
    -- Set value
    volume:connect_signal('property::value', function()
        if env.sound_system == "alsa" then
            aspawn.with_shell('amixer -D ' .. env.sound_card_alsa .. ' sset Master ' .. volume.value .. '%')
        else
            aspawn.with_shell('pactl set-sink-mute @DEFAULT_SINK@ false ; pactl set-sink-volume @DEFAULT_SINK@ ' .. volume.value .. '%')
        end
    end)
    -- get volume
    awesome.connect_signal("daemon::volume", function(vol, is_muted)
        volume:set_value(vol)
    end)
    return w
end

function volume_root:make_progressbar_vert(p)
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

function volume_root:make_progressbar()
    local p  = widget.make_progressbar(_, self.bar_size, { self.bar_colors[1][1], self.bar_colors[2] })
    local wp = widget.progressbar_layout(p, self.want_layout)
    local w
    if self.want_layout == 'vertical' then
        w = self:make_progressbar_vert(wp)
    else
        w = widget.box_with_margin(self.want_layout, { self.wicon, wp }, 8)
    end
    awesome.connect_signal("daemon::volume", function(vol, is_muted)
        p.value           = vol
        self.wtext.markup = helpers.colorize_text(vol .. " %", beautiful.fg_grey)
    end)
    return w
end

-- herit
local volume_widget = class(volume_root)

function volume_widget:init(args)
    volume_root.init(self, args)
    return self.widget
end

return volume_widget
