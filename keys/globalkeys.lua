local awful     = require("awful")
local gears     = require("gears")
local programms = require("programms")
local hotkeys   = require("keys.hotkeys")
local switcher  = require("widgets.switcher")
local fun       = require("functions")

local key       = capi.event.key

local global    = gears.table.join(
--[[ AWESOME ]]--
        awful.key({ key.shift, key.mod }, key.r,
                  function()
                      fun:on_restart()
                  end, hotkeys.awesome.restart),

        awful.key({ key.shift, key.mod }, key.q,
                  function()
                      fun:on_quit()
                  end, hotkeys.awesome.quit),

        awful.key({ key.mod }, key.s,
                  function()
                      fun:on_show_help()
                  end, hotkeys.awesome.help),

        awful.key({ key.win, key.shift }, key.v,
                  function()
                      --capi.undermouse = true
                      awful.util.spawn("copyq show")
                  end,
                  { description = "+10%", group = "hotkeys" }
        ),

-- Brightness
        awful.key({}, key.brightness.XF86MonBrightnessUp,
                  function()
                      awesome.emit_signal("brightness_change", "+")
                  end,
                  { description = "Brightness +25%", group = "hotkeys" }
        ),
        awful.key({}, key.brightness.XF86MonBrightnessDown,
                  function()
                      awesome.emit_signal("brightness_change", "-")
                  end,
                  { description = "Brightness -25%", group = "hotkeys" }
        ),

-- ALSA volume control
        awful.key({}, key.audio.XF86AudioRaiseVolume,
                  function()
                      awesome.emit_signal("volume_change", "+")
                  end,
                  { description = "volume up", group = "hotkeys" }
        ),

        awful.key({}, key.audio.XF86AudioLowerVolume,
                  function()
                      awesome.emit_signal("volume_change", "-")
                  end,
                  { description = "volume down", group = "hotkeys" }
        ),

        awful.key({}, key.audio.XF86AudioMute,
                  function()
                      awesome.emit_signal("volume_change", "off")
                  end,
                  { description = "toggle mute", group = "hotkeys" }
        ),

        awful.key({}, key.audio.XF86AudioNext,
                  function()
                      awful.spawn("playerctl next", false)
                  end,
                  { description = "next music", group = "hotkeys" }
        ),

        awful.key({}, key.audio.XF86AudioPrev,
                  function()
                      awful.spawn("playerctl previous", false)
                  end,
                  { description = "previous music", group = "hotkeys" }
        ),

        awful.key({}, key.audio.XF86AudioPlay,
                  function()
                      awful.spawn("playerctl play-pause", false)
                      awesome.emit_signal("spotify_change")
                  end,
                  { description = "play/pause music", group = "hotkeys" }
        ),

--[[ COMMAND ]]--
        awful.key({ key.ctrl, key.altL }, key.delete,
                  function()
                      fun:on_run(programms.htop)
                  end, hotkeys.command.htop),

        awful.key({ }, key.print,
                  function()
                      fun:on_run(programms.screenshot)
                  end, hotkeys.command.printscreen),


-- Tag browsing
        awful.key({ key.mod }, key.bracket_left,
                  function()
                      awful.tag.viewprev()
                  end, hotkeys.tag.previous),

        awful.key({ key.mod }, key.bracket_right,
                  function()
                      awful.tag.viewnext()
                  end, hotkeys.tag.next),


        awful.key({ key.mod }, key.tab,
                  function()
                      awful.tag.history.restore()
                  end, hotkeys.tag.restore),


        awful.key({ key.altL }, key.tab,
                  function()
                      switcher(key.alt_L, key.tab)

                      --awful.client.focus.history.previous()
                      --if client.focus then
                      --    client.focus:raise()
                      --end
                  end, hotkeys.client.previous),


--[[ Programms ]]--
        awful.key({ key.mod }, key.e,
                  function()
                      fun:on_run(programms.manager)
                  end, hotkeys.programm.manager),

        awful.key({ key.mod }, key.r,
                  function()
                      fun:on_run(programms.rofi)
                  end, hotkeys.programm.run),

        awful.key({ key.ctrl, key.altL }, key.t,
                  function()
                      fun:on_run(programms.terminal)
                  end, hotkeys.programm.terminal),

        awful.key({ key.mod }, key.l,
                  function()
                      fun:on_run(programms.lockscreen)
                  end, hotkeys.programm.lockscreen),


-- Device button
        awful.key({ }, key.system.poweroff,
                  function()
                      -- TODO
                      -- добавить сохранение данных
                      -- когда выключает ПК
                      -- (отловить событие poweroff)
                      -- (тк, можем и через команду выключить)
                  end),


-- Test key
        awful.key({ key.win, key.shift }, key.p,
                  function()
                      fun:on_run(programms.terminal .. " xev | grep 'keycode'")
                  end),


-- Test key
        awful.key({ }, key.test.XF86Search,
                  function()
                      fun:on_run(programms.htop)
                  end, hotkeys.command.htop),

        awful.key({ }, key.test.XF86Favorites,
                  function()
                      fun:on_run(programms.htop)
                  end, hotkeys.command.htop)

)

return global
