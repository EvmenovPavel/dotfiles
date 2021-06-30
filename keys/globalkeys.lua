local awful     = require("awful")
local gears     = require("gears")
local key       = capi.wmapi.event.key
local programms = require("programms")
local hotkeys   = require("keys.hotkeys")
local switcher  = require("widgets.switcher")

local fun       = require("functions")

--local function move_to_previous_tag()
--    local c = client.focus
--    if not c then return end
--    local t = c.screen.selected_tag
--    local tags = c.screen.tags
--    local idx = t.index
--    local newtag = tags[gmath.cycle(#tags, idx - 1)]
--    c:move_to_tag(newtag)
--    --awful.tag.viewprev()
--end
--
--local function move_to_next_tag()
--    local c = client.focus
--    if not c then return end
--    local t = c.screen.selected_tag
--    local tags = c.screen.tags
--    local idx = t.index
--    local newtag = tags[gmath.cycle(#tags, idx + 1)]
--    c:move_to_tag(newtag)
--    --awful.tag.viewnext()
--end

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

--awful.key({ key.win, key.shift }, key.tab,
--          function()
--switcher.switch(-1, "Mod1", "Alt_L", "Shift", "Tab")
--end),

--awful.key({ key.win }, "f", function()
--capi.mouse.screen.selected_tag.selected = false
--for _, t in ipairs(mouse.screen.selected_tags) do
--    t.selected = false
--end
--end),

--awful.key({ key.win, key.altL }, "Right",
--          function()
--              awful.tag.incmwfact(0.01)
--          end),
--awful.key({ key.win, key.altL }, "Left",
--          function()
--              awful.tag.incmwfact(-0.01)
--          end),
--awful.key({ key.win, key.altL }, "Down",
--          function()
--              awful.client.incwfact(0.01)
--          end),
--awful.key({ key.win, key.altL }, "Up",
--          function()
--              awful.client.incwfact(-0.01)
--          end),


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
                      awful.spawn("sudo brightness +25", false)
                  end,
                  { description = "Brightness +25%", group = "hotkeys" }
        ),
        awful.key({}, key.brightness.XF86MonBrightnessDown,
                  function()
                      awful.spawn("sudo brightness -25", false)
                  end,
                  { description = "Brightness -25%", group = "hotkeys" }
        ),

-- ALSA volume control
        awful.key({}, key.audio.XF86AudioRaiseVolume,
                  function()
                      awful.spawn("amixer -D pulse sset Master 5%+", false)
                      capi.awesome.emit_signal("volume_change")
                  end,
                  { description = "volume up", group = "hotkeys" }
        ),

        awful.key({}, key.audio.XF86AudioLowerVolume,
                  function()
                      awful.spawn("amixer -D pulse sset Master 5%-", false)
                      capi.awesome.emit_signal("volume_change")
                  end,
                  { description = "volume down", group = "hotkeys" }
        ),

        awful.key({}, key.audio.XF86AudioMute,
                  function()
                      awful.spawn("amixer -D pulse set Master 1+ toggle", false)
                      capi.awesome.emit_signal("volume_change")
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
                      capi.awesome.emit_signal("spotify_change")
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
                      switcher.switch(key.alt_L, key.tab)

                      awful.client.focus.history.previous()
                      if client.focus then
                          client.focus:raise()
                      end
                      --menu.client_list({ theme = { width = 250 } })
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
