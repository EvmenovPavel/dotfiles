local beautiful = require("beautiful")

local theme     = require("theme")

theme:theme(beautiful)
theme:titlebar(beautiful)
theme:taglist(beautiful)
theme:tasklist(beautiful)
theme:menu(beautiful)
theme:wibar(beautiful)

function print(...)
    -- log:debug("print:", ...)
end

local keybinds = require("keys.keybinds")
root.keys(keybinds.globalkeys)
root.buttons(keybinds.buttonkeys)

local awful       = require("awful")
awful.rules.rules = require("rules")(keybinds.clientkeys, keybinds.buttonkeys)

local apps        = require("autostart")
apps:start()

require("modules.titlebar")
local wibar     = require("wibar")
local wallpaper = require("modules.wallpaper")

awful.screen.connect_for_each_screen(
        function(s)
            wallpaper(s)
            wibar(s)

            for i, icon in pairs(beautiful.taglist_icons) do
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

require("awful.autofocus")

client.connect_signal("focus",
                      function(c)
                          c.border_color = beautiful.bg_focus
                          c:raise()
                          c.opacity = 1
                      end)

client.connect_signal("unfocus",
                      function(c)
                          if c.maximized or c.fullscreen then
                              c.border_color = beautiful.border_normal
                          else
                              c.border_color = color.disabled_inner
                          end

                          c.opacity = 0.3
                          c:raise()
                      end)
