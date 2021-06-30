local beautiful           = require("lib.beautiful")
local dpi                 = beautiful.xresources.apply_dpi
local widget              = require("util.widgets")
local button              = require("util.buttons")
local helpers             = require("helpers")
local aspawn              = require("lib.awful.spawn")
local wibox               = require("lib.wibox")

-- beautiful vars
local icon_prev           = beautiful.widget_mpc_prev_icon
local icon_pause          = beautiful.widget_mpc_pause_icon
local icon_play           = beautiful.widget_mpc_play_icon
local icon_stop           = beautiful.widget_mpc_stop_icon
local icon_next           = beautiful.widget_mpc_next_icon
-- for titlebar
local icon_ncmpcpp_prev   = beautiful.widget_ncmpcpp_prev
local icon_ncmpcpp_toggle = beautiful.widget_ncmpcpp_toggle
local icon_ncmpcpp_next   = beautiful.widget_ncmpcpp_next

-- command
local prev_cmd            = function()
    aspawn("mpc prev", false)
end
local toggle_cmd          = function()
    aspawn("mpc toggle", false)
end
local next_cmd            = function()
    aspawn("mpc next", false)
end

-- root
local mpc_root            = class()

function mpc_root:init(args)
    -- options
    self.mode           = args.mode or 'text' -- possible values: text, titlebar
    self.size           = args.size or beautiful.widget_icon_font:match('([0-9]+)') or 16 -- font size
    self.size_ncmpcpp   = args.size or 20 -- font size
    self.colors         = args.colors or { beautiful.fg_grey, beautiful.fg_grey_light } -- fg, fg light for the hover
    self.colors_ncmpcpp = args.colors or { beautiful.alert, beautiful.alert_light } -- fg, fg light for the hover
    self.spacing        = args.spacing or dpi(7)
    self.want_layout    = args.layout or beautiful.widget_mpc_layout or 'horizontal' -- possible values: horizontal , vertical
    -- base widgets
    self:base_widget()
    self.widget = self:make_widget()
end

function mpc_root:base_widget()
    if self.mode == "titlebar" then
        self.wicon_prev   = button.create(icon_ncmpcpp_prev, self.colors_ncmpcpp[2], self.colors_ncmpcpp[1], prev_cmd, self.size_ncmpcpp)
        self.wicon_toggle = button.create(icon_ncmpcpp_toggle, self.colors_ncmpcpp[2], self.colors_ncmpcpp[1], toggle_cmd, self.size_ncmpcpp)
        self.wicon_next   = button.create(icon_ncmpcpp_next, self.colors_ncmpcpp[2], self.colors_ncmpcpp[1], next_cmd, self.size_ncmpcpp)
    else
        self.wicon_prev   = button.create(icon_prev, self.colors[2], self.colors[1], prev_cmd, self.size)
        self.wicon_toggle = button.create(icon_play, self.colors[2], self.colors[1], toggle_cmd, self.size)
        self.wicon_next   = button.create(icon_next, self.colors[2], self.colors[1], next_cmd, self.size)
    end
end

function mpc_root:make_widget()
    if self.mode == "titlebar" then
        return self:make_for_titlebar()
    else
        return self:make_text()
    end
end

function mpc_root:make_text()
    local w = widget.box_with_margin(self.want_layout, { self.wicon_prev, self.wicon_toggle, self.wicon_next }, self.spacing)

    awesome.connect_signal("daemon::mpd", function(mpd)
        if (mpd.status == "playing") then
            self.wicon_toggle.markup = helpers.colorize_text(icon_pause, self.colors[1])
        elseif (mpd.status == "paused") then
            self.wicon_toggle.markup = helpers.colorize_text(icon_play, self.colors[1])
        elseif (mpd.status == "void") then
            self.wicon_toggle.markup = helpers.colorize_text(icon_play, self.colors[1])
        else
            self.wicon_toggle.markup = helpers.colorize_text(icon_stop, self.colors[1])
        end
    end)

    return w
end

function mpc_root:make_for_titlebar()
    local w = wibox.widget {
        nil,
        widget.box('horizontal', { self.wicon_prev, self.wicon_toggle, self.wicon_next }, self.spacing),
        nil,
        expand = "none",
        layout = wibox.layout.align.vertical
    }
    return w
end

-- herit
local mpc_widget = class(mpc_root)

function mpc_widget:init(args)
    mpc_root.init(self, args)
    return self.widget
end

return mpc_widget
