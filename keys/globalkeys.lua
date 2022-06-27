local awful     = require("awful")
local gears     = require("gears")

local programms = require("programms")

local hotkeys   = require("keys.hotkeys")
local switcher  = require("widgets.switcher")
local fun       = require("functions")

--local keyboardlayout = require("keyboardlayout")

local global    = gears.table.join(
--[[ AWESOME ]]--
        awful.key({ event.key.mod, event.key.shift }, event.key.r,
                  function()
                      fun:on_restart()
                  end, hotkeys.awesome.restart),

        awful.key({ event.key.mod, event.key.shift }, event.key.q,
                  function()
                      fun:on_quit()
                  end, hotkeys.awesome.quit),

        awful.key({ event.key.mod }, event.key.s,
                  function()
                      fun:on_show_help()
                  end, hotkeys.awesome.help),

        awful.key({ event.key.win, event.key.shift }, event.key.v,
                  function()
                      awful.util.spawn("copyq show")
                  end,
                  { description = "+10%", group = "hotkeys" }
        ),

-- Brightness
        awful.key({}, event.key.brightness.XF86MonBrightnessUp,
                  function()
                      awesome.emit_signal("brightness_change", "+")
                      awesome.emit_signal("volume_change", "disable")
                  end,
                  { description = "Brightness +25%", group = "hotkeys" }
        ),
        awful.key({}, event.key.brightness.XF86MonBrightnessDown,
                  function()
                      awesome.emit_signal("brightness_change", "-")
                      awesome.emit_signal("volume_change", "disable")
                  end,
                  { description = "Brightness -25%", group = "hotkeys" }
        ),

-- ALSA volume control
        awful.key({}, event.key.audio.XF86AudioRaiseVolume,
                  function()
                      awesome.emit_signal("volume_change", "+")
                      awesome.emit_signal("brightness_change", "disable")
                  end,
                  { description = "volume up", group = "hotkeys" }
        ),

        awful.key({}, event.key.audio.XF86AudioLowerVolume,
                  function()
                      awesome.emit_signal("volume_change", "-")
                      awesome.emit_signal("brightness_change", "disable")
                  end,
                  { description = "volume down", group = "hotkeys" }
        ),

        awful.key({}, event.key.audio.XF86AudioMute,
                  function()
                      awesome.emit_signal("volume_change", "off")
                      awesome.emit_signal("brightness_change", "disable")
                  end,
                  { description = "toggle mute", group = "hotkeys" }
        ),

        awful.key({}, event.key.audio.XF86AudioNext,
                  function()
                      awful.spawn("playerctl next", false)
                  end,
                  { description = "next music", group = "hotkeys" }
        ),

        awful.key({}, event.key.audio.XF86AudioPrev,
                  function()
                      awful.spawn("playerctl previous", false)
                  end,
                  { description = "previous music", group = "hotkeys" }
        ),

        awful.key({}, event.key.audio.XF86AudioPlay,
                  function()
                      awful.spawn("playerctl play-pause", false)
                      awesome.emit_signal("spotify_change")
                  end,
                  { description = "play/pause music", group = "hotkeys" }
        ),

--[[ COMMAND ]]--
        awful.key({ event.key.ctrl, event.key.altL }, event.key.delete,
                  function()
                      fun:on_run(programms.htop)
                  end, hotkeys.command.htop),

        awful.key({ }, event.key.print,
                  function()
                      fun:on_run(programms.screenshot)
                  end, hotkeys.command.printscreen),


-- Tag browsing
        awful.key({ event.key.mod }, event.key.bracket_left,
                  function()
                      awful.tag.viewprev()
                  end, hotkeys.tag.previous),

        awful.key({ event.key.mod }, event.key.bracket_right,
                  function()
                      awful.tag.viewnext()
                  end, hotkeys.tag.next),


        awful.key({ event.key.mod }, event.key.tab,
                  function()
                      awful.tag.history.restore()
                  end, hotkeys.tag.restore),


        awful.key({ event.key.altL }, event.key.tab,
                  function()
                      switcher(event.key.alt_L, event.key.tab)

                      --awful.client.focus.history.previous()
                      --if client.focus then
                      --    client.focus:raise()
                      --end
                  end, hotkeys.client.previous),


--[[ Programms ]]--
        awful.key({ event.key.mod }, event.key.e,
                  function()
                      fun:on_run(programms.manager)
                  end, hotkeys.programm.manager),

        awful.key({ event.key.mod }, event.key.r,
                  function()
                      --if ("ru" == keyboardlayout:name()) then

                      --end

                      fun:on_run(programms.rofi)
                  end, hotkeys.programm.run),

        awful.key({ event.key.ctrl, event.key.altL }, event.key.t,
                  function()
                      fun:on_run(programms.terminal)
                  end, hotkeys.programm.terminal),

        awful.key({ event.key.mod }, event.key.l,
                  function()
                      fun:on_run(programms.lockscreen)
                  end, hotkeys.programm.lockscreen),


-- Device button
        awful.key({ }, event.key.system.poweroff,
                  function()
                      -- TODO
                      -- добавить сохранение данных
                      -- когда выключает ПК
                      -- (отловить событие poweroff)
                      -- (тк, можем и через команду выключить)
                  end),


-- Test key
        awful.key({ event.key.win, event.key.shift }, event.key.p,
                  function()
                      fun:on_run(programms.terminal .. " xev | grep 'keycode'")
                  end)
--,


-- Test key
--        awful.key({ }, key.test.XF86Search,
--                  function()
--                      fun:on_run(programms.htop)
--                  end, hotkeys.command.htop),
--
--        awful.key({ }, key.test.XF86Favorites,
--                  function()
--                      fun:on_run(programms.htop)
--                  end, hotkeys.command.htop)

)

return global
