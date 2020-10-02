local gears      = require("gears")
local awful      = require("awful")
local key        = require("event").key
local hotkeys    = require("keys.hotkeys")

local fun        = require("functions")

local clientkeys = gears.table.join(
        awful.key({ key.shift, key.mod }, key.f,
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

        awful.key({ key.alt_L }, key.F4,
                  function(c)
                      fun:on_close(c)
                  end, hotkeys.client.kill),

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
                  end, hotkeys.client.floating)
)

return clientkeys
