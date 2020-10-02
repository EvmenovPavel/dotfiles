local awful         = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local functions     = {}

function functions:on_backproc()
    awful.screen.focused().quake:toggle()
end

function functions:on_restart()
    awesome.restart()
end

function functions:on_quit()
    awesome.quit()
end

function functions:on_show_help()
    hotkeys_popup.show_help()
end

function functions:on_run(cmd)
    awful.util.spawn(cmd)
end

function functions:on_fullscreen(c)
    c.fullscreen = not c.fullscreen
end

function functions:on_maximized(c)
    if c.fullscreen then
        c.fullscreen = false
    end

    c.floating  = false
    c.maximized = not c.maximized
end

function functions:on_fullscreen(c)
    if c.maximized then
        c.maximized = false
    end

    c.fullscreen = not c.fullscreen
end

function functions:on_minimized(c)
    c.minimized = not c.minimized
end

function functions:on_close(c)
    c:kill()
end

function functions:on_kill(c)
    c:kill()
end

function functions:on_sticky(c)
    c.sticky = not c.sticky
end

function functions:on_ontop(c)
    c.ontop = not c.ontop
end

function functions:on_floating(c)
    c.maximized = false
    c.floating  = not c.floating
end

return functions