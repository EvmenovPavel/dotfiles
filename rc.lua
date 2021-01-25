-- Global --
capi            = {
    root    = root,
    screen  = screen,
    primary = screen[2],
    tag     = tag,
    dbus    = dbus,
    button  = button,
    client  = client,
    awesome = awesome,
    mouse   = mouse,
    timer   = timer,
    unpack  = unpack,
    log     = require("logger"),
    home    = os.getenv("HOME"),
    path    = os.getenv("HOME") .. "/.config/awesome",
    wmapi   = require("wmapi"),
}

local awful     = require("awful")
local gears       = require("gears")
local pixbuf      = require("lgi").GdkPixbuf
local setmetatable = setmetatable
local tostring     = tostring
local ipairs       = ipairs
local error        = error
local wibox        = require("wibox")
local beautiful    = require("beautiful")
local gdebug       = require("gears.debug")
local placement    = require("awful.placement")
local widgets   = require("widgets")

local theme     = require("theme")

beautiful.init(theme)

local keybinds = require("keys.keybinds")
capi.root.keys(keybinds.globalkeys)
capi.root.buttons(keybinds.buttonkeys)

require("notifications")

awful.rules.rules = require("rules")(keybinds.clientkeys, keybinds.buttonkeys)

local apps        = require("autostart")
apps:start()

require("widgets.titlebar")
--local wibar     = require("wibar")
--local wallpaper = require("wallpaper")

local mywallpaper = {}

function mywallpaper:set_animated(surf, s)
    local img, err = pixbuf.PixbufAnimation.new_from_file(surf)
    if not img then
        print(err)
    else
        local iter = img:get_iter(nil)

        local function set_wp()
            local geom, cr = gears.wallpaper.prepare_context(s)
            iter:advance(nil)
            cr:set_source_pixbuf(iter:get_pixbuf(), 0, 0)
            cr.operator = "SOURCE"
            cr:paint()
            local delay = iter:get_delay_time()
            if delay ~= -1 then
                gears.timer.start_new(delay / 1000, set_wp)
            end
        end
        set_wp()
    end
end

local list_wallpaper = {
    { "anime", "png" },
    { "spider-verse-triple", "png" },
    { "wp2503419", "png" },
    { "retrowave", "jpg" },
    { "no_game_no_life", "png" },
    { "pixel", "jpg" }
}

function mywallpaper:create(s)

    local wallpaper = list_wallpaper[4]

    local file      = beautiful.wallpapers .. "/" .. wallpaper[1] .. "/" .. capi.wmapi:display_index(s) .. "." .. wallpaper[2]

    if type(file) == "function" then
        file = file(s)
    end

    gears.wallpaper.maximized(file, s, true)
end

local mywibar   = {}

function mywibar:w_left(s)
    return {
        widgets.taglist:create(s),
        layout = wibox.layout.fixed.horizontal
    }
end

function mywibar:w_middle(s)
    return {
        widgets.tasklist:create(s),
        layout = wibox.layout.fixed.horizontal
    }
end

function mywibar:w_right(s)
    if capi.wmapi:display_primary(s) then
        return {
            widgets.systray(s),
            widgets.keyboard(),
            widgets.volume(s),
            --widgets.cpu(),
            widgets.pad(),
            --widgets.memory(),
            widgets.clock(),
            widgets.reboot(),
            --widgets.pacmd(),
            --widgets.spotify(s),

            layout = wibox.layout.fixed.horizontal
        }
    end

    return {
        layout = wibox.layout.fixed.horizontal
    }
end

function mywibar:create(s)
    local wibar = awful.wibar({
                                  ontop        = false,
                                  stretch      = true,
                                  position     = beautiful.position.top,
                                  border_width = 1,
                                  border_color = beautiful.bg_dark,
                                  --bg           = "#00000099",
                                  fg           = beautiful.fg_normal,
                                  visible      = true,
                                  height       = 27,
                                  screen       = s,
                              })

    wibar:setup {
        self:w_left(s),
        self:w_middle(s),
        self:w_right(s),
        layout = wibox.layout.align.horizontal,
    }

    return mywibar
end

awful.screen.connect_for_each_screen(
        function(s)
            mywallpaper:create(s)
            mywibar:create(s)

            for i, tag in pairs(theme.taglist_icons) do
                awful.tag.add(i, {
                    icon      = tag.icon,
                    icon_only = true,
                    layout    = awful.layout.suit.tile,
                    screen    = s,
                    selected  = i == 1
                })
            end
        end
)

capi.tag.connect_signal("property::layout", function(t)
    local current_layout = awful.tag.getproperty(t, "layout")

    if (current_layout == awful.layout.suit.max) then
        t.gap = 0
    else
        t.gap = beautiful.useless_gap
    end
end)

capi.client.connect_signal("manage", function(c)
    if not capi.awesome.startup then
        awful.client.setslave(c)
    end

    if capi.awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

require("awful.autofocus")