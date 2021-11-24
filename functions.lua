local awful         = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local functions     = {}

function functions:on_backproc()
    awful.screen.focused().quake:toggle()
end

local client_iterate = require("awful.client").iterate
local gtable         = require("gears.table")

function clients(filter)
    local item_args = {}

    local cls_t     = {}
    for c in client_iterate(filter or
                                    function()
                                        return true
                                    end)
    do
        if not c.valid then
            return
        end

        cls_t[#cls_t + 1] = {
            name      = c.name,
            tag       = c.tag,
            tags      = c.tags,
            instance  = c.instance,
            class     = c.class,
            screen    = c.screen,
            icon      = c.icon,
            exec_once = c.exec_once,
        }

        gtable.merge(cls_t[#cls_t], item_args)
    end

    return cls_t
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
    -- как делает floating = true
    -- узнаем размер экрана и делаем виджет по центру


    --local screen = capi.wmapi.screen()
    --local geometry = capi.wmapi.screen_geometry(screen)

    --local x     = c.x
    --local y     = c.y

    c.maximized = false
    c.floating  = not c.floating

    --if (c.floating) then
    --    c.x = x - c.width
    --    c.y = y - c.height / 2
    --end
end

return functions