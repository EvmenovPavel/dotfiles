local beautiful = require("beautiful")
local theme     = require("theme")
beautiful.init(theme)

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

require("awful.autofocus")

--local scripts = require("scripts")
--scripts.xrandr()

--local signal = require("posix.signal")

--signal.signal(signal.SIGINT, function(signum)
--    log:debug("signum: " .. tostring(signum))
--    -- put code to save some stuff here
--    --os.exit(128 + signum)
--end)

--if [ "`systemctl is-system-running`" = "stopping" ]; then
--# Do what you need
--end
