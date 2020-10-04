local beautiful   = require("beautiful")
local gears       = require("gears")
local pixbuf      = require("lgi").GdkPixbuf

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
    { "anime", "png" },
    { "spider-verse-triple", "png" },
    { "wp2503419", "png" },
    { "retrowave", "jpg" },
    { "no_game_no_life", "png" },
    { "pixel", "jpg" }
}

function mywallpaper:create(s)

    local wallpaper = list_wallpaper[4]

    local file      = beautiful.wallpapers .. "/" .. wallpaper[1] .. "/" .. capi.wmapi:display_index(s) .. "." .. wallpaper[2]

    if type(file) == "function" then
        file = file(s)
    end

    gears.wallpaper.maximized(file, s, true)
end

return mywallpaper