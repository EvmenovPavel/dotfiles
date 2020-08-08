local gears     = require("lib.gears")
local config    = require("config")

local _         = require("lib.lgi").Gdk
local pixbuf    = require("lib.lgi").GdkPixbuf

local wallpaper = {}

local function index(s)
    for i = 1, screen.count() do
        if s == screen[i] then
            return i
        end
    end

    return 1
end

function wallpaper:set_animated(surf, s)
    local img, err = pixbuf.PixbufAnimation.new_from_file(surf)
    if not img then
        print(err)
    else
        local iter = img:get_iter(nil)

        local function set_wp()
            local geom, cr = gears.wallpaper.prepare_context(s)
            iter:advance(nil)
            cr:set_source_pixbuf(iter:get_pixbuf(), 0, 0)
            cr.operator = "SOURCE"
            cr:paint()
            local delay = iter:get_delay_time()
            if delay ~= -1 then
                gears.timer.start_new(delay / 1000, set_wp)
            end
        end
        set_wp()
    end
end

local w = {
    "anime",
    "spider-verse-triple",
    "wp2503419"
}

function wallpaper:set_wallpaper(s)
    local file = config.wallpaper .. w[2] .. "/" .. index(s) .. ".png"

    if type(file) == "function" then
        file = file(s)
    end

    gears.wallpaper.maximized(file, s, true)

    --screen.connect_signal("property::geometry", set_wallpaper)
end

return wallpaper