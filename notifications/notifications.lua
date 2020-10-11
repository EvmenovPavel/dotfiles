local naughty                        = require("naughty")
local beautiful                      = require("beautiful")
local gears                          = require("gears")

local icon_notification              = capi.path .. "/notification/plugin-notification.svg"

naughty.config.defaults.ontop        = true
naughty.config.defaults.icon_size    = 32

naughty.config.defaults.font         = beautiful.font

naughty.config.defaults.title        = "Title: System Notification"
naughty.config.defaults.text         = "Text: System Notification"

naughty.config.defaults.margin       = 16
naughty.config.defaults.border_width = 2
naughty.config.defaults.position     = "top_right"

naughty.config.defaults.width        = 322

naughty.config.defaults.shape        = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, 5)
end

naughty.config.padding               = 7
naughty.config.spacing               = 7
--naughty.config.icon_dirs             = {
--    --изменить пусть к иконкам
--    "/usr/share/icons/Tela-dark",
--    "/usr/share/pixmaps/"
--}
--
--naughty.config.icon_formats          = {
--    "png",
--    "svg",
--}

naughty.config.notify_callback       = nil

--function naughty:init(s)
--  naughty.config.defaults.screen = s
--end

naughty.config.presets.normal        = {
    fg            = beautiful.fg_normal,
    bg            = beautiful.bg_normal,

    level         = 1,

    timeout       = 5,
    hover_timeout = 5,

    title         = "Title normal",
    text          = "Text normal",
}

naughty.config.presets.low           = {
    fg            = beautiful.fg_normal,
    bg            = beautiful.bg_normal,

    level         = 2,

    timeout       = 5,
    hover_timeout = 5,

    title         = "Title low",
    text          = "Text low",
}

naughty.config.presets.critical      = {
    fg            = "#ffffff",
    bg            = "#ff0000",

    level         = 3,

    timeout       = 10,
    hover_timeout = 10,

    title         = "Title critical",
    text          = "Text critical",
}

naughty.config.presets.ok            = {
    fg            = beautiful.fg_normal,
    bg            = beautiful.bg_normal,

    level         = 1,

    timeout       = 5,
    hover_timeout = 5,

    title         = "Title normal",
    text          = "Text normal",
}

naughty.config.presets.info          = {
    fg            = beautiful.fg_normal,
    bg            = beautiful.bg_normal,

    level         = 1,

    timeout       = 5,
    hover_timeout = 5,

    title         = "Title normal",
    text          = "Text normal",
}

naughty.config.presets.warn          = {
    fg            = "#ffffff",
    bg            = "#ff0000",

    level         = 3,

    timeout       = 10,
    hover_timeout = 10,

    title         = "Title critical",
    text          = "Text critical",
}

if capi.awesome.startup_errors then
    local preset = naughty.config.presets.critical
    local title  = "Oops, there were errors during startup!"
    local text   = capi.awesome.startup_errors

    --notification:append({ presets = preset, title = title, text = text })

    naughty.notify({
                       preset = preset,
                       title  = title,
                       text   = text
                   })
end

do
    local in_error = false
    capi.awesome.connect_signal(
            "debug::error",
            function(err)
                if in_error then
                    return
                end

                in_error     = true

                local preset = naughty.config.presets.critical
                local title  = "Oops, an error happened!"
                local text   = tostring(err)

                --notification:append({ presets = preset, title = title, text = text })

                naughty.notify({
                                   preset = preset,
                                   title  = title,
                                   text   = text
                               })
                in_error = false
            end
    )
end

function naughty:show(args)
    local args = args or {}

    if naughty.config.notify_callback then
        args = naughty.config.notify_callback(args)
        if not args then
            return
        end
    end

    local preset        = args.preset or naughty.config.presets.normal

    local timeout       = args.timeout or preset.timeout
    local hover_timeout = args.hover_timeout or preset.hover_timeout

    local icon          = args.icon or icon_notification

    local title         = args.title or preset.title
    local text          = args.text or preset.text

    --notification:append({ presets = preset, title = title, text = text, icon = icon })

    --if not notification.panel_notification.visible then
    naughty.notify {
        preset        = preset,

        icon          = icon,
        title         = title,
        text          = text,

        timeout       = timeout,
        hover_timeout = hover_timeout,
    }
    --end
end