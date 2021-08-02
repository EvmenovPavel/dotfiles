local wibox              = require("wibox")
local awful              = require("awful")
local gears              = require("gears")

local resources          = require("resources")

local amixer_volume      = "amixer -D pulse sget Master | grep 'Left:' | awk -F '[][]' '{print $2}' | sed 's/[^0-9]//g'"
local amixer_active      = "amixer -D pulse sget Master | grep 'Left:' | awk -F '[][]' '{print $4}'"

local volume             = {}
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
    image  = resources.widgets.volume.on,
    widget = wibox.widget.imagebox
}

local hide_volume_adjust = gears.timer {
    timeout   = 3,
    autostart = true,
    callback  = function()
        volume_adjust.visible = false
    end
}

function volume:on_images()
    awful.spawn.easy_async_with_shell(
            amixer_active,
            function(stdout)
                if string.sub(stdout, 0, 2) == "on" then
                    w_volume_icon:set_image(resources.widgets.volume.on)
                elseif string.sub(stdout, 0, 3) == "off" then
                    w_volume_icon:set_image(resources.widgets.volume.off)
                end
            end,
            false
    )
end

function volume:on_volume()
    awful.spawn.easy_async_with_shell(
            amixer_volume,
            function(stdout)
                w_volume_bar.value = tonumber(stdout)
                volume:on_images()
            end,
            false
    )
end

capi.awesome.connect_signal("volume_change",
                            function()
                                if volume_adjust.visible then
                                    hide_volume_adjust:again()
                                else
                                    volume_adjust.visible = true
                                    hide_volume_adjust:start()
                                    hide_volume_adjust:again()
                                end

                                volume:on_volume()
                            end
)

function volume:init()
    local offsetx = 48
    local offsety = 300

    volume_adjust = wibox({
                              x       = capi.primary * capi.wmapi:screenWidth(capi.primary) - offsetx,
                              y       = capi.wmapi:screenHeight() / 2 - offsety / 2,

                              width   = offsetx,
                              height  = offsety,

                              shape   = gears.shape.rounded_rect,
                              visible = false,
                              ontop   = true
                          })

    volume_adjust:setup {
        layout = wibox.layout.align.vertical,
        {
            wibox.container.margin(
                    w_volume_bar, 14, 20, 20, 20
            ),
            forced_height = 300 * 0.75,
            direction     = "east",
            layout        = wibox.container.rotate,
        },
        wibox.container.margin(
                w_volume_icon,
                7, 7, 14, 14
        )
    }

    return w_volume_icon
end

return setmetatable(volume, {
    __call = volume.init
})
