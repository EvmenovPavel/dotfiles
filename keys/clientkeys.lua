local gears    = require("lib.gears")
local awful    = require("lib.awful")
local keyboard = require("keys.key")
local hotkeys  = require("keys.hotkeys")

require("functions")

local client = gears.table.join(
--awful.button({ keyboard.win }, 1, awful.mouse.client.move),
--awful.button({ keyboard.win }, 3, awful.mouse.client.resize),

--awful.button({}, 1,
--             function(c)
--                 client.focus = c
--                 c:raise()
--             end
--),

        awful.key({ keyboard.shift, keyboard.mod }, keyboard.f,
                  function(c)
                      on_fullscreen(c)
                  end, hotkeys.client.maximized),

        awful.key({ keyboard.mod }, keyboard.f,
                  function(c)
                      on_maximized(c)
                  end, hotkeys.client.maximized),

        awful.key({ keyboard.mod }, keyboard.n,
                  function(c)
                      on_minimized(c)
                  end, hotkeys.client.minimized),

        awful.key({ keyboard.alt_L }, keyboard.F4,
                  function(c)
                      on_close(c)
                  end, hotkeys.client.kill),

        awful.key({ keyboard.mod }, keyboard.t,
                  function(c)
                      on_floating(c)
                  end, hotkeys.client.floating),

        awful.key({ keyboard.mod }, keyboard.y,
                  function(c)
                      on_ontop(c)
                  end, hotkeys.client.ontop),

        awful.key({ keyboard.mod }, keyboard.u,
                  function(c)
                      on_sticky(c)
                  end, hotkeys.client.floating)
)

return client