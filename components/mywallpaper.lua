local gears       = require("lib.gears")
local pixbuf      = require("lib.lgi").GdkPixbuf
local wmapi       = require("lib.wmapi")
local config      = require("config")

local mywallpaper = {}

function mywallpaper:set_animated(surf, s)
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

local list_wallpaper = {
    "anime",
    "spider-verse-triple",
    "wp2503419"
}

function mywallpaper:set_wallpaper(s)
    local file = config.path_wallpaper .. "/" .. list_wallpaper[2] .. "/" .. wmapi:display_index(s) .. ".png"

    if type(file) == "function" then
        file = file(s)
    end

    gears.wallpaper.maximized(file, s, true)
end

return mywallpaper