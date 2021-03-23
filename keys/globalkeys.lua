local awful     = require("awful")
local gears     = require("gears")
local key       = capi.wmapi.event.key
local programms = require("programms")
local hotkeys   = require("keys.hotkeys")
--local gmath     = require("gmath")

--local switcher  = require("widgets.switcher")

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


--awful.key({ key.alt_L, }, key.tab,
--          function()
--switcher.switch(1, key.mod, "Alt_L", "Shift", "Tab")
--switcher:switch(1, key.win, key.alt_L, key.shift, key.tab)
--end),

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

--awful.key({ key.win, key.alt_L }, "Right",
--          function()
--              awful.tag.incmwfact(0.01)
--          end),
--awful.key({ key.win, key.alt_L }, "Left",
--          function()
--              awful.tag.incmwfact(-0.01)
--          end),
--awful.key({ key.win, key.alt_L }, "Down",
--          function()
--              awful.client.incwfact(0.01)
--          end),
--awful.key({ key.win, key.alt_L }, "Up",
--          function()
--              awful.client.incwfact(-0.01)
--          end),


        awful.key({key.win, key.shift }, key.v,
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
                  { description = "+10%", group = "hotkeys" }
        ),
        awful.key({}, key.brightness.XF86MonBrightnessDown,
                  function()
                      awful.spawn("sudo brightness -25", false)
                  end,
                  { description = "-10%", group = "hotkeys" }
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
        awful.key({ key.ctrl, key.alt_L }, key.delete,
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
                      fun:on_run(programms.manager)
                  end, hotkeys.programm.manager),

        awful.key({ key.mod }, key.r,
                  function()
                      fun:on_run(programms.rofi)
                  end, hotkeys.programm.run),

        awful.key({ key.ctrl, key.alt_L }, key.t,
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
                  end)
)

return global
