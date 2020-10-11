local wibox             = require("lib.wibox")
local awful             = require("lib.awful")
local beautiful         = require("lib.beautiful")
local naughty           = require("lib.naughty")
local widget            = require("util.widgets")
local helpers           = require("helpers")
local dpi               = beautiful.xresources.apply_dpi
local icons             = require("icons.default")
local gtable            = require("lib.gears.table")

-- widget for the popup
local mpc               = require("widgets.mpc")({ size = 16 })
local volume_bar        = require("widgets.volume")({ mode = "slider" })
volume_bar.forced_width = dpi(40) -- set a max width

-- beautiful vars
local icon              = beautiful.widget_mpc_button_icon or "  "
local fg                = beautiful.widget_volume_fg
local bg                = beautiful.widget_volume_bg
local font_button       = beautiful.widget_icon_font_button or 'Iosevka Term 16'
local l                 = beautiful.widget_button_music_layout or 'horizontal'

-- for the popup
local fg_p              = beautiful.fg_grey or "#aaaaaa"
local bg_p              = beautiful.grey_dark or "#222222" -- same than the wibar
local padding           = beautiful.widget_popup_padding or 1

local music_player_root = class()

function music_player_root:init(args)
    -- options
    self.icon        = args.icon or beautiful.widget_mpd_icon or { icon, beautiful.fg_grey }
    self.mode        = args.mode or 'popup' -- possible values: block, popup, song
    self.wposition   = args.position or widget.check_popup_position(beautiful.wibar_position)
    -- widgets
    self.wicon       = widget.base_icon(self.icon[1], self.icon[2])
    self.title       = widget.base_text()
    self.artist      = widget.base_text()
    self.cover       = widget.imagebox(90)
    self.time_pasted = widget.base_text()
    self.widget      = self:make_widget()
end

function music_player_root:make_widget()
    if self.mode == "block" then
        return self:make_block()
    elseif self.mode == "song" then
        return self:make_song()
    else
        return self:make_popup()
    end
end

function music_player_root:make_block()
    self.title.align               = "left"
    self.title.forced_height       = dpi(10) -- adjust to have one line
    self.time_pasted.align         = "left"
    self.time_pasted.forced_height = dpi(10) -- adjust to have one line
    self.cover.forced_height       = dpi(60)
    self.cover.forced_width        = dpi(60)
    local w                        = wibox.widget {
        {
            self.cover,
            {
                widget.add_margin(self.title, { bottom = 5 }),
                widget.add_margin(self.time_pasted, { top = 3, bottom = 5 }),
                mpc,
                layout = wibox.layout.fixed.vertical
            },
            layout = wibox.layout.align.horizontal
        },
        forced_height = 80,
        top           = dpi(10), bottom = dpi(10), -- adjust in order to limit the name to one line
        widget        = wibox.container.margin
    }
    self:signals()
    return w
end

function music_player_root:create_popup(w)
    local img   = wibox.widget {
        {
            nil,
            {
                self.cover,
                {
                    nil,
                    {
                        nil,
                        nil,
                        mpc,
                        expand = "none",
                        layout = wibox.layout.align.vertical
                    },
                    expand = "none",
                    layout = wibox.layout.align.horizontal
                },
                --vertical_offset = 10,
                layout = wibox.layout.stack
            },
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        forced_height = 80,
        forced_width  = 80,
        widget        = wibox.container.margin
    }
    local desc  = wibox.widget {
        self.title,
        self.artist,
        self.time_pasted,
        {
            volume_bar,
            left   = 6, right = 6,
            widget = wibox.container.margin
        },
        spacing = dpi(2),
        layout  = wibox.layout.fixed.vertical
    }
    self.wpopup = awful.popup {
        widget              = {
            {
                nil,
                {
                    nil,
                    {
                        img,
                        desc,
                        spacing = 20,
                        layout  = wibox.layout.fixed.horizontal
                    },
                    expand = "none",
                    layout = wibox.layout.align.horizontal
                },
                expand = "none",
                layout = wibox.layout.align.vertical
            },
            top          = dpi(14),
            bottom       = dpi(14),
            forced_width = dpi(340),
            widget       = wibox.container.margin
        },
        visible             = false, -- do not show at start
        ontop               = true,
        hide_on_right_click = true,
        preferred_positions = self.wposition,
        offset              = { y = padding, x = padding }, -- no pasted on the bar
        bg                  = bg_p,
        shape               = helpers.rrect(15)
    }

    -- attach popup to widget
    self.wpopup:bind_to_widget(w)
end

function music_player_root:make_popup()
    -- widget creation
    local button = widget.create_button(fg, icon)
    self:create_popup(button)
    self:signals()
    return widget.box(layout, { button })
end

-- update
function music_player_root:updates(mpd)
    -- default value
    local img          = mpd.cover ~= nil and mpd.cover or icons["default_cover"]
    local title        = mpd.title ~= nil and "<b>" .. mpd.title .. "</b>" or 'Unknown'
    local artist       = mpd.artist ~= nil and mpd.artist or 'Unknown'

    self.cover.image   = img
    self.title.markup  = helpers.colorize_text(title, beautiful.alert)
    self.artist.markup = helpers.colorize_text("By " .. artist, beautiful.primary)
end

function music_player_root:update_time(mpd)
    self.time_pasted.markup = helpers.colorize_text(mpd.full_time, beautiful.secondary)
end

-- signals
function music_player_root:signals()
    awesome.connect_signal("daemon::mpd", function(mpd)
        self:updates(mpd)
    end)
    awesome.connect_signal("daemon::mpd_time", function(mpd)
        self:update_time(mpd)
    end)
end

function music_player_root:make_song()
    local w = wibox.widget {
        self.wicon,
        self.title,
        spacing = beautiful.widget_spacing or 10,
        layout  = wibox.layout.fixed.horizontal
    }
    self:create_popup(w)
    self.wpopup.x = dpi(4)
    self.wpopup.y = beautiful.wibar_size + dpi(4)
    w:connect_signal('mouse::enter', function()
        self.wpopup.visible = true
    end)
    w:buttons(gtable.join(
            awful.button({}, 1, function()
                self.wpopup.visible = false
            end),
            awful.button({}, 3, function()
                self.wpopup.visible = false
            end)
    ))
    self:signals()
    return w
end

-- herit
local music_player_widget = class(music_player_root)

function music_player_widget:init(args)
    music_player_root.init(self, args)
    return self.widget
end

return music_player_widget
