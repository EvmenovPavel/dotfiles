local awful         = require("awful")
local gears         = require("gears")
local beautiful     = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local functions     = {}

function functions:on_backproc()
    awful.screen.focused().quake:toggle()
end

local client_iterate = require("awful.client").iterate
local gtable         = require("gears.table")

function functions:logs(c)
    --log:debug(
    --        "\nname:", c.name,
    --        "\nskip_taskbar:", c.skip_taskbar,
    --        "\nclass:", c.class,
    --        "\ninstance:", c.instance,
    --        "\npid:", c.pid,
    --        "\nrole:", c.role,
    --        "\nicon_name:", c.icon_name,
    --        "\nicon:", c.icon,
    --        "\nicon_sizes:", c.icon_sizes,
    --        "\ngroup_window:", c.group_window,
    --        "\nstartup_id:", c.startup_id,
    --        "\nborder_width:", c.border_width,
    --        "\nmaximized:", c.maximized,
    --        "\nfullscreen:", c.fullscreen,
    --        "\nmaximized_horizontal:", c.maximized_horizontal,
    --        "\nmaximized_vertical:", c.maximized_vertical,
    --        "\nwidth:", c.width,
    --        "\nheight:", c.height,
    --        "\n\n"
    --)
end

function functions:update_client(c)
    if c.maximized or c.fullscreen then
        c.border_width = 0
        c.shape        = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 0)
        end
    else
        c.border_width = 4
        c.shape        = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, beautiful.shape_rounded_rect)
        end
    end

    c:raise()
end

local function clients(filter)
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

function functions:on_maximized(c, state)
    c.fullscreen = false
    c.floating   = false

    c.maximized  = not c.maximized

    self:update_client(c)
end

function functions:on_fullscreen(c)
    c.maximized  = false
    c.floating   = false

    c.fullscreen = not c.fullscreen

    self:update_client(c)
end

function functions:on_minimized(c)
    c.minimized = not c.minimized
    c:raise()
end

function functions:on_close(c)
    c:kill()
end

function functions:on_kill(c)
    c:kill()
end

function functions:on_sticky(c, state)
    c.sticky = not c.sticky
    c:raise()
end

function functions:on_ontop(c, state)
    c.ontop = not c.ontop
    c:raise()
end

function functions:on_floating(c)
    -- как делает floating = true
    -- узнаем размер экрана и делаем виджет по центру


    --local screen = wmapi.screen()
    --local geometry = wmapi.screen_geometry(screen)

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