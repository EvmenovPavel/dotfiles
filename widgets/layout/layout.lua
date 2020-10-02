local awful        = require("awful")
local resource     = require("resource")

local layouts      = {}

local layouts_list = {
    floating        = {
        status = true,
        icon   = resource.layout.floating,
        layout = awful.layout.suit.floating
    },

    tile            = {
        status = true,
        icon   = resource.layout.tile,
        layout = awful.layout.suit.tile
    },

    left            = {
        status = true,
        icon   = resource.layout.left,
        layout = awful.layout.suit.tile.left
    },

    bottom          = {
        status = true,
        icon   = resource.layout.tile.bottom,
        layout = awful.layout.suit.tile.bottom
    },

    tile_top        = {
        status = true,
        icon   = resource.layout.tile.top,
        layout = awful.layout.suit.tile.top
    },

    fair            = {
        status = true,
        icon   = resource.layout.fair,
        layout = awful.layout.suit.fair
    },

    fair_horizontal = {
        status = true,
        icon   = resource.layout.fair.horizontal,
        layout = awful.layout.suit.fair.horizontal
    },

    spiral          = {
        status = true,
        icon   = resource.layout.spiral,
        layout = awful.layout.suit.spiral
    },

    dwindle         = {
        status = true,
        icon   = resource.layout.dwindle,
        layout = awful.layout.suit.dwindle
    },

    max             = {
        status = true,
        icon   = resource.layout.max,
        layout = awful.layout.suit.max
    },

    max_fullscreen  = {
        status = true,
        icon   = resource.layout.max.fullscreen,
        layout = awful.layout.suit.max.fullscreen
    },

    magnifier       = {
        status = true,
        icon   = resource.layout.magnifier,
        layout = awful.layout.suit.magnifier
    },
}

--mylayoutbox[s] = awful.widget.layoutbox(s)
--mylayoutbox[s]:buttons(awful.util.table.join(
--        awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
--        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
--        awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
--        awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

return layouts