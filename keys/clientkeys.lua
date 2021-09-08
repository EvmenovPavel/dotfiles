local gears      = require("gears")
local awful      = require("awful")
local hotkeys    = require("keys.hotkeys")
local fun        = require("functions")

local clientkeys = gears.table.join(
        awful.key({ capi.event.key.shift, capi.event.key.mod }, capi.event.key.f,
                  function(c)
                      fun:on_fullscreen(c)
                  end, hotkeys.client.maximized),

        awful.key({ capi.event.key.mod }, capi.event.key.f,
                  function(c)
                      fun:on_maximized(c)
                  end, hotkeys.client.maximized),

        awful.key({ capi.event.key.mod }, capi.event.key.n,
                  function(c)
                      fun:on_minimized(c)
                  end, hotkeys.client.minimized),

        awful.key({ capi.event.key.altL }, capi.event.key.F4,
                  function(c)
                      fun:on_close(c)
                  end, hotkeys.client.kill),

        awful.key({ capi.event.key.mod }, capi.event.key.t,
                  function(c)
                      fun:on_floating(c)
                  end, hotkeys.client.floating),

        awful.key({ capi.event.key.mod }, capi.event.key.y,
                  function(c)
                      fun:on_ontop(c)
                  end, hotkeys.client.ontop),

        awful.key({ capi.event.key.mod }, capi.event.key.u,
                  function(c)
                      fun:on_sticky(c)
                  end, hotkeys.client.floating)
)

return clientkeys
