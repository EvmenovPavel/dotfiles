local wibox              = require("wibox")
local awful              = require("awful")
local gears              = require("gears")
local beautiful          = require("beautiful")
local dpi                = beautiful.xresources.apply_dpi

local offsetx            = dpi(56)
local offsety            = dpi(300)
local screen             = awful.screen.focused()

local amixer_volume      = "amixer -D pulse sget Master | grep 'Left:' | awk -F '[][]' '{print $2}' | sed 's/[^0-9]//g'"
local amixer_active      = "amixer -D pulse sget Master | grep 'Left:' | awk -F '[][]' '{print $4}'"

local icon               = {
    on  = gears.filesystem.get_configuration_dir() .. "/icons/volume/volume_on.png",
    off = gears.filesystem.get_configuration_dir() .. "/icons/volume/volume_off.png"
}

local volume_adjust      = {}

local w_volume_bar       = wibox.widget {
    widget           = wibox.widget.progressbar,
    shape            = gears.shape.rounded_bar,
    color            = "#efefef",
    background_color = "#000000",
    max_value        = 100,
    value            = 0
}

local w_volume_icon      = wibox.widget {
    image  = icon.on,
    widget = wibox.widget.imagebox
}

local hide_volume_adjust = gears.timer {
    timeout   = 3,
    autostart = true,
    callback  = function()
        volume_adjust.visible = false
    end
}

local function on_volume()
    awful.spawn.easy_async_with_shell(
            amixer_volume,
            function(stdout)
                w_volume_bar.value = tonumber(stdout)
            end,
            false
    )
end

local function on_images()
    awful.spawn.easy_async_with_shell(
            amixer_active,
            function(stdout)
                if string.sub(stdout, 0, 2) == "on" then
                    w_volume_icon:set_image(icon.on)
                elseif string.sub(stdout, 0, 3) == "off" then
                    w_volume_icon:set_image(icon.off)
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
                           if volume_adjust.visible then
                               hide_volume_adjust:again()
                           else
                               volume_adjust.visible = true
                               hide_volume_adjust:start()
                               hide_volume_adjust:again()
                           end
                       end
)

--awesome.connect_signal("volume_change_raise",
--                       function()
--                           awful.spawn("amixer -D pulse sset Master 5%+", false)
--                           on_amixer()
--                       end
--)

--awesome.connect_signal("volume_change_lower",
--                       function()
--                           awful.spawn("amixer -D pulse sset Master 5%-", false)
--                           on_amixer()
--                       end
--)

--awesome.connect_signal("volume_change_mute",
--                       function()
--                           awful.spawn("amixer -D pulse set Master 1+ toggle", false)
--                           on_amixer()
--                       end
--)

local function worker(s)
    volume_adjust = wibox({
                              screen  = s,
                              x       = screen.geometry.width - offsetx,
                              y       = (screen.geometry.height / 2) - (offsety / 2),
                              width   = dpi(48),
                              height  = offsety,
                              shape   = gears.shape.rounded_rect,
                              visible = false,
                              ontop   = true
                          })

    volume_adjust:setup {
        layout = wibox.layout.align.vertical,
        {
            wibox.container.margin(
                    w_volume_bar, dpi(14), dpi(20), dpi(20), dpi(20)
            ),
            forced_height = offsety * 0.75,
            direction     = "east",
            layout        = wibox.container.rotate,
        },
        wibox.container.margin(
                w_volume_icon,
                dpi(7), dpi(7), dpi(14), dpi(14)
        )
    }
end

local volume = {}

return setmetatable(volume, { __call = function(_, ...)
    return worker(...)
end })
