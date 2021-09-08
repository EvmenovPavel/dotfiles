require("capi")

local beautiful = require("beautiful")
local theme     = require("theme")
beautiful.init(theme)

local keybinds = require("keys.keybinds")
root.keys(keybinds.globalkeys)
root.buttons(keybinds.buttonkeys)

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

tag.connect_signal("property::layout", function(t)
    local current_layout = awful.tag.getproperty(t, "layout")

    if (current_layout == awful.layout.suit.max) then
        t.gap = 0
    else
        t.gap = beautiful.useless_gap
    end
end)

client.connect_signal("manage", function(c)
    if not awesome.startup then
        awful.client.setslave(c)
    end

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

require("awful.autofocus")