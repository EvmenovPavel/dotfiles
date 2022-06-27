local naughty                        = require("lib.naughty")
local beautiful                      = require("beautiful")
local gears                          = require("gears")

naughty.config.defaults.ontop        = true
naughty.config.defaults.icon_size    = 32

naughty.config.defaults.font         = beautiful.font

naughty.config.defaults.title        = "Title: System Notification"
naughty.config.defaults.text         = "Text: System Notification"

naughty.config.defaults.margin       = 16
naughty.config.defaults.border_width = 0
naughty.config.defaults.position     = placement.top_right

naughty.config.defaults.width        = 322

naughty.config.defaults.shape        = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, 5)
end

naughty.config.padding               = 7
naughty.config.spacing               = 7

naughty.config.notify_callback       = nil

naughty.config.defaults.screen       = wmapi:screen_primary()

naughty.config.presets.normal        = {
    fg            = beautiful.fg_normal,
    bg            = "#74C045",

    level         = 1,

    timeout       = 5,
    hover_timeout = 5,

    title         = "Title normal",
    text          = "Text normal",
}

naughty.config.presets.low           = {
    fg            = beautiful.fg_normal,
    bg            = "#FECC0C",

    level         = 2,

    timeout       = 5,
    hover_timeout = 5,

    title         = "Title low",
    text          = "Text low",
}

naughty.config.presets.critical      = {
    fg            = beautiful.fg_normal,
    bg            = "#EF3F2A",

    level         = 3,

    timeout       = 10,
    hover_timeout = 10,

    title         = "Title critical",
    text          = "Text critical",
}

--naughty.config.presets.ok            = {
--    fg            = beautiful.fg_normal,
--    bg            = "#7FFFFF",
--
--    level         = 1,
--
--    timeout       = 5,
--    hover_timeout = 5,
--
--    title         = "Title normal",
--    text          = "Text normal",
--}

naughty.config.presets.info          = {
    fg            = beautiful.fg_normal,
    bg            = "#FF7FED",

    level         = 1,

    timeout       = 5,
    hover_timeout = 5,

    title         = "Title info",
    text          = "Text info",
}

naughty.config.presets.warn          = {
    fg            = beautiful.fg_normal,
    bg            = "#DCDCDC",

    level         = 3,

    timeout       = 10,
    hover_timeout = 10,

    title         = "Title warn",
    text          = "Text warn",
}

if awesome.startup_errors then
    local preset = naughty.config.presets.critical
    local title  = "Oops, there were errors during startup!"
    local text   = awesome.startup_errors

    log:debug("title: " .. title, "text: " .. text)

    naughty.notify({
                       preset = preset,
                       title  = title,
                       text   = text
                   })

end

return naughty