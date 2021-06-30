local wibox       = require("lib.wibox")
local awful       = require("lib.awful")
local naughty     = require("lib.naughty")
local beautiful   = require("lib.beautiful")

local font_icon   = beautiful.widget_icon_font or 'RobotoMono Nerd Font Mono 18'
local markup_icon = beautiful.widget_hostname_text_icon or '<span foreground="#948a77">  </span>'

distrib_icon      = wibox.widget {
    markup = markup_icon,
    --align = 'left',
    --valign = 'top',
    widget = wibox.widget.textbox,
    font   = font_icon
}

function host_show()
    awful.spawn.easy_async([[bash -c "uname -n"]],
                           function(stdout, stderr, reason, exitcode)
                               naughty.notify {
                                   text          = stdout,
                                   title         = "Actual Host ",
                                   timeout       = 5,
                                   hover_timeout = 5,
                                   width         = 124,
                                   position      = "top_left",
                               }
                           end
    )
end

distrib_icon:connect_signal("mouse::enter", function()
    host_show()
end)
