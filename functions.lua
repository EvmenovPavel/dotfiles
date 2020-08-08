local awful         = require("lib.awful")
local hotkeys_popup = require("lib.awful.hotkeys_popup").widget

function on_backproc()
    awful.screen.focused().quake:toggle()
end

function on_restart()
    awesome.restart()
end

function on_quit()
    awesome.quit()
end

function on_show_help()
    hotkeys_popup.show_help()
end

function on_run(command)
    awful.util.spawn(command)
end

function on_fullscreen(c)
    c.fullscreen = not c.fullscreen
end

function on_maximized(c)
    if c.fullscreen then
        c.fullscreen = false
    end

    c.maximized = not c.maximized
end

function on_fullscreen(c)
    if c.maximized then
        c.maximized = false
    end

    logger:info(c.class)
    logger:info(c.instance)
    c.fullscreen = not c.fullscreen
end

function on_minimized(c)
    c.minimized = not c.minimized
end

function on_close(c)
    c:kill()
end

function on_kill(c)
    c:kill()
end

function on_sticky(c)
    c.sticky = not c.sticky
end

function on_ontop(c)
    c.ontop = not c.ontop
end

function on_floating(c)
    c.maximized = false
    c.floating  = not c.floating
end