local awful     = require("lib.awful")
local gears     = require("lib.gears")
local key       = require("keys.key")
local programms = require("device.programms")
local hotkeys   = require("keys.hotkeys")

local switcher  = require("widgets.switcher")

--switcher.settings.preview_box                        = true -- display preview-box
--switcher.settings.preview_box_bg                     = "#ddddddaa" -- background color
--switcher.settings.preview_box_border                 = "#22222200" -- border-color
--switcher.settings.preview_box_fps                    = 30 -- refresh framerate
--switcher.settings.preview_box_delay                  = 150 -- delay in ms
--switcher.settings.preview_box_title_font             = { "sans", "italic", "normal" } -- the font for cairo
--switcher.settings.preview_box_title_font_size_factor = 0.8 -- the font sizing factor
--switcher.settings.preview_box_title_color            = { 0, 0, 0, 1 } -- the font color
--
--switcher.settings.client_opacity                     = false -- opacity for unselected clients
--switcher.settings.client_opacity_value               = 0.5 -- alpha-value for any client
--switcher.settings.client_opacity_value_in_focus      = 0.5 -- alpha-value for the client currently in focus
--switcher.settings.client_opacity_value_selected      = 1 -- alpha-value for the selected client
--
--switcher.settings.cycle_raise_client                 = true -- raise clients on cycle

require("functions")

local global = gears.table.join(
--awful.key({ key.alt_L, }, key.tab,
--          function()
--switcher.switch(1, key.mod, "Alt_L", "Shift", "Tab")
--switcher:switch(1, key.win, key.alt_L, key.shift, key.tab)
--end),

--awful.key({ key.win, key.shift }, key.tab,
--          function()
--switcher.switch(-1, "Mod1", "Alt_L", "Shift", "Tab")
--end),


-- Brightness
        awful.key({}, key.brightness.XF86MonBrightnessUp,
                  function()
                      awful.spawn("xbacklight -inc 10", false)
                  end,
                  { description = "+10%", group = "hotkeys" }
        ),
        awful.key({}, key.brightness.XF86MonBrightnessDown,
                  function()
                      awful.spawn("xbacklight -dec 10", false)
                  end,
                  { description = "-10%", group = "hotkeys" }
        ),

-- ALSA volume control
        awful.key({}, key.audio.XF86AudioRaiseVolume,
                  function()
                      awful.spawn("amixer -D pulse sset Master 5%+", false)
                      awesome.emit_signal("volume_change")
                      --awesome.emit_signal("volume_change_raise")
                  end,
                  { description = "volume up", group = "hotkeys" }
        ),
        awful.key({}, key.audio.XF86AudioLowerVolume,
                  function()
                      awful.spawn("amixer -D pulse sset Master 5%-", false)
                      awesome.emit_signal("volume_change")
                      --awesome.emit_signal("volume_change_lower")
                  end,
                  { description = "volume down", group = "hotkeys" }
        ),
        awful.key({}, key.audio.XF86AudioMute,
                  function()
                      awful.spawn("amixer -D pulse set Master 1+ toggle", false)
                      awesome.emit_signal("volume_change")
                      --awesome.emit_signal("volume_change_mute")
                  end,
                  { description = "toggle mute", group = "hotkeys" }
        ),
        awful.key({}, key.audio.XF86AudioNext,
                  function()
                      awful.spawn("mpc next", false)
                  end,
                  { description = "next music", group = "hotkeys" }
        ),
        awful.key({}, key.audio.XF86AudioPrev,
                  function()
                      awful.spawn("mpc prev", false)
                  end,
                  { description = "previous music", group = "hotkeys" }
        ),
        awful.key({}, key.audio.XF86AudioPlay,
                  function()
                      awful.spawn("mpc toggle", false)
                  end,
                  { description = "play/pause music", group = "hotkeys" }
        ),


--[[ AWESOME ]]--
        awful.key({ key.shift, key.mod }, key.r,
                  function()
                      on_restart()
                  end, hotkeys.awesome.restart),

        awful.key({ key.ctrl, key.mod }, key.q,
                  function()
                      on_quit()
                  end, hotkeys.awesome.quit),

        awful.key({ key.mod }, key.s,
                  function()
                      on_show_help()
                  end, hotkeys.awesome.help),


--[[ AUDACIOUS ]]--
--        awful.key({ }, key.system.audio.play,
--                  function()
--                      on_run("audacious --play-pause")
--                  end, hotkeys.audacious.play),
--
--        awful.key({ }, key.system.audio.next,
--                  function()
--                      on_run("audacious --fwd")
--                  end, hotkeys.audacious.next),
--
--        awful.key({ }, key.system.audio.prev,
--                  function()
--                      on_run("audacious --rew")
--                  end, hotkeys.audacious.prev),


--[[ COMMAND ]]--
        awful.key({ key.ctrl, key.alt_L }, key.delete,
                  function()
                      on_run(programms.terminal .. " htop")
                  end, hotkeys.command.htop),

        awful.key({ }, key.print,
                  function()
                      on_run(programms.screenshot)
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

--awful.key({ key.mod }, key.tab,
--          function()
--              awful.tag.history.restore()
--          end, hotkeys.tag.restore),

        awful.key({ key.alt_L }, key.tab,
                  function()
                      awful.client.focus.history.previous()
                      if client.focus then
                          client.focus:raise()
                      end
                      --menu.client_list({ theme = { width = 250 } })
                  end, hotkeys.client.previous),


--[[ Programms ]]--
        awful.key({ key.mod }, key.e,
                  function()
                      on_run(programms.manager)
                  end, hotkeys.programm.manager),

        awful.key({ key.mod }, key.r,
                  function()
                      on_run(programms.run)
                  end, hotkeys.programm.run),

        awful.key({ key.ctrl, key.alt_L }, key.t,
                  function()
                      on_run(programms.terminal)
                  end, hotkeys.programm.terminal),

        awful.key({ key.mod }, key.l,
                  function()
                      on_run(programms.lockscreen)
                  end, hotkeys.programm.lockscreen),


-- Device button
        awful.key({ }, key.system.poweroff,
                  function()
                  end)


-- Brightness
-- увеличивает яркость
--        awful.key({ }, keyboard.fn, keyboard.F12,
--        awful.key({ keyboard.win }, keyboard.up,
--                  function()
--                      on_run("sudo brightnessctl s 10%+")
--                  end,
--                  { description = "+10%", group = "hotkeys" }),
---- уменьшает яркость
----        awful.key({ }, keyboard.fn, keyboard.F11,
--        awful.key({ keyboard.win }, keyboard.down,
--                  function()
--                      on_run("sudo brightnessctl s 10%-")
--                  end,
--                  { description = "-10%", group = "hotkeys" }),
--

---- ALSA volume control
--        awful.key({ }, keyboard.system.volume.raise,
--                  function()
--                      --os.execute(string.format(amixer.volumeRaise,
--                      --                         beautiful.volume.channel))
--                      --beautiful.volume.update()
--                  end,
--                  { description = "volume up", group = "ALSA volume control" }),
--
--        awful.key({ }, keyboard.system.volume.lower,
--                  function()
--                      --os.execute(string.format(amixer.volumeLower,
--                      --                         beautiful.volume.channel))
--                      --beautiful.volume.update()
--                  end,
--                  { description = "volume down", group = "ALSA volume control" }),
--
--        awful.key({ }, keyboard.system.volume.mute,
--                  function()
--                      --os.execute(string.format(amixer.volumeMute,
--                      --                         beautiful.volume.togglechannel or beautiful.volume.channel))
--                      --beautiful.volume.update()
--                  end,
--                  { description = "toggle mute", group = "ALSA volume control" })
)

return global
