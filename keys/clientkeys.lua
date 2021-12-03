local gears      = require("gears")
local awful      = require("awful")
local hotkeys    = require("keys.hotkeys")
local fun        = require("functions")
local key        = capi.event.key

local clientkeys = gears.table.join(
        awful.key({ key.mod, key.shift }, key.f,
                  function(c)
                      fun:on_fullscreen(c)
                  end, hotkeys.client.maximized),

        awful.key({ key.mod }, key.f,
                  function(c)
                      fun:on_maximized(c)
                  end, hotkeys.client.maximized),

        awful.key({ key.mod }, key.n,
                  function(c)
                      fun:on_minimized(c)
                  end, hotkeys.client.minimized),

        awful.key({ key.altL }, key.F4,
                  function(c)
                      fun:on_close(c)
                  end, hotkeys.client.kill),

        awful.key({ key.mod, key.altL }, key.F4,
                  function(c)
                      --грубое убивание процесса
                      --fun:on_close(c)
                      capi.log:message("sudo key.F4")
                  end, hotkeys.client.sudo_kill),

        awful.key({ key.mod }, key.t,
                  function(c)
                      fun:on_floating(c)
                  end, hotkeys.client.floating),

        awful.key({ key.mod }, key.y,
                  function(c)
                      fun:on_ontop(c)
                  end, hotkeys.client.ontop),

        awful.key({ key.mod }, key.u,
                  function(c)
                      fun:on_sticky(c)
                  end, hotkeys.client.floating),

        awful.key({ key.mod, key.shift }, key.bracket_left,
                  function(c)
                      capi.log:message("key.bracket_left")
                      --fun:on_sticky(c)
                  end, hotkeys.client.floating),

        awful.key({ key.mod, key.shift }, key.bracket_right,
                  function(c)
                      capi.log:message("key.bracket_right")
                      --fun:on_sticky(c)
                  end, hotkeys.client.floating)
)

return clientkeys
