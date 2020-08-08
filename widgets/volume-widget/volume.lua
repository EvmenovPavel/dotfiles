local wibox         = require("lib.wibox")
local awful         = require("lib.awful")
local gears         = require("lib.gears")
local beautiful     = require("lib.beautiful")
local dpi           = beautiful.xresources.apply_dpi

local offsetx       = dpi(56)
local offsety       = dpi(300)
local screen        = awful.screen.focused()

local amixer_volume = "amixer -D pulse sget Master | grep 'Left:' | awk -F '[][]' '{print $2}' | sed 's/[^0-9]//g'"
local amixer_active = "amixer -D pulse sget Master | grep 'Right:' | awk -F '[][]' '{print $4}'"

local icon_on       = gears.filesystem.get_configuration_dir() .. "/icons/volume/volume_on.png"
local icon_off      = gears.filesystem.get_configuration_dir() .. "/icons/volume/volume_off.png"

-- ===================================================================
-- Appearance & Functionality
-- ===================================================================

-- create the volume_adjust component
local volume_adjust = wibox({
                                --screen  = awful.screen.focused(),
                                x       = screen.geometry.width - offsetx,
                                y       = (screen.geometry.height / 2) - (offsety / 2),
                                width   = dpi(48),
                                height  = offsety,
                                shape   = gears.shape.rounded_rect,
                                visible = false,
                                ontop   = true
                            })

local volume_bar    = wibox.widget {
    widget           = wibox.widget.progressbar,
    shape            = gears.shape.rounded_bar,
    color            = "#efefef",
    background_color = beautiful.bg_focus,
    max_value        = 100,
    value            = 0
}

local volume_icon   = wibox.widget {
    image  = "",
    widget = wibox.widget.imagebox
}

volume_adjust:setup {
    layout = wibox.layout.align.vertical,
    {
        wibox.container.margin(
                volume_bar, dpi(14), dpi(20), dpi(20), dpi(20)
        ),
        forced_height = offsety * 0.75,
        direction     = "east",
        layout        = wibox.container.rotate,
    },
    wibox.container.margin(
            volume_icon,
            dpi(7), dpi(7), dpi(14), dpi(14)
    )
}

-- create a 3 second timer to hide the volume adjust
-- component whenever the timer is started
local hide_volume_adjust = gears.timer {
    timeout   = 3,
    autostart = true,
    callback  = function()
        volume_adjust.visible = false
    end
}

local function on_amixer()
    -- make volume_adjust component visible
    if volume_adjust.visible then
        hide_volume_adjust:again()
    else
        volume_adjust.visible = true
        hide_volume_adjust:start()
    end
end

local function on_volume()
    awful.spawn.easy_async_with_shell(
            amixer_volume,
            function(stdout)
                volume_bar.value = tonumber(stdout)
            end,
            false
    )
end

local function on_images()
    awful.spawn.easy_async_with_shell(
            amixer_active,
            function(stdout)
                if string.sub(stdout, 0, 2) == "on" then
                    volume_icon:set_image(icon_on)
                elseif string.sub(stdout, 0, 3) == "off" then
                    volume_icon:set_image(icon_off)
                end
            end,
            false
    )
end

gears.timer {
    timeout   = 0.1,
    call_now  = true,
    autostart = true,
    callback  = function()
        on_volume()
        on_images()
    end
}

awesome.connect_signal("volume_change",
                       function()
                           on_amixer()
                       end
)

awesome.connect_signal("volume_change_raise",
                       function()
                           awful.spawn("amixer -D pulse sset Master 5%+", false)
                           on_amixer()
                       end
)

awesome.connect_signal("volume_change_lower",
                       function()
                           awful.spawn("amixer -D pulse sset Master 5%-", false)
                           on_amixer()
                       end
)

awesome.connect_signal("volume_change_mute",
                       function()
                           awful.spawn("amixer -D pulse set Master 1+ toggle", false)
                           on_amixer()
                       end
)