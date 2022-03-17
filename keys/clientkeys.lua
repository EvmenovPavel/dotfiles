local gears      = require("gears")
local awful      = require("awful")
local hotkeys    = require("keys.hotkeys")
local fun        = require("functions")

local event      = require("lib.event")

local clientkeys = gears.table.join(
        awful.key({ event.key.mod, event.key.shift }, event.key.f,
                  function(c)
                      fun:on_fullscreen(c)
                  end, hotkeys.client.maximized),

        awful.key({ event.key.mod }, event.key.f,
                  function(c)
                      fun:on_maximized(c)
                  end, hotkeys.client.maximized),

        awful.key({ event.key.mod }, event.key.n,
                  function(c)
                      fun:on_minimized(c)
                  end, hotkeys.client.minimized),

        awful.key({ event.key.altL }, event.key.F4,
                  function(c)
                      fun:on_close(c)
                  end, hotkeys.client.kill),

        awful.key({ event.key.mod, event.key.altL }, event.key.F4,
                  function(c)
                      --грубое убивание процесса
                      --fun:on_close(c)
                      log:debug("sudo event.key.F4")
                  end, hotkeys.client.sudo_kill),

        awful.key({ event.key.mod }, event.key.t,
                  function(c)
                      fun:on_floating(c)
                  end, hotkeys.client.floating),

        awful.key({ event.key.mod }, event.key.y,
                  function(c)
                      fun:on_ontop(c)
                  end, hotkeys.client.ontop),

        awful.key({ event.key.mod }, event.key.u,
                  function(c)
                      fun:on_sticky(c)
                  end, hotkeys.client.floating),

        awful.key({ event.key.mod, event.key.shift }, event.key.bracket_left,
                  function(c)
                      log:debug("key.bracket_left")
                      --fun:on_sticky(c)
                  end, hotkeys.client.floating),

        awful.key({ event.key.mod, event.key.shift }, event.key.bracket_right,
                  function(c)
                      log:debug("key.bracket_right")
                      --fun:on_sticky(c)
                  end, hotkeys.client.floating)
)

return clientkeys
