require("capi")
require("awful.autofocus")
--require("autofocus")

local beautiful = require("beautiful")
local theme     = require("theme")
beautiful.init(theme)

local keybinds = require("keys.keybinds")
capi.root.keys(keybinds.globalkeys)
capi.root.buttons(keybinds.buttonkeys)

require("notifications")

local awful       = require("awful")
awful.rules.rules = require("rules")(keybinds.clientkeys, keybinds.buttonkeys)

local apps        = require("autostart")
apps:start()

require("widgets.titlebar")
local wibar     = require("wibar")
local wallpaper = require("wallpaper")

awful.screen.connect_for_each_screen(
        function(s)
            wallpaper(s)
            wibar(s)

            for i, icon in pairs(theme.taglist_icons) do
                awful.tag.add(i, {
                    icon      = icon,
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

capi.client.connect_signal("mouse::enter",
                           function(c)
                               c:emit_signal("request::activate", "mouse_enter", { raise = false })
                               --c:emit_signal('request::activate', "", { raise = not capi.awesome.startup })
                           end
)
