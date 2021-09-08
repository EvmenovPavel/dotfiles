local wibox                  = require("wibox")
local awful                  = require("awful")
local gears                  = require("gears")

local resources              = require("resources")

local current                = "sudo brightness -s | grep 'current_bright:' | awk -F '[][]' '{print $1}' | sed 's/[^0-9]//g'"
local max_bright             = "sudo brightness -s | grep 'max_bright:' | awk -F '[][]' '{print $1}' | sed 's/[^0-9]//g'"

local brightness             = {}
local brightness_adjust      = {}

local w_brightness_bar       = wibox.widget {
    widget           = wibox.widget.progressbar,
    shape            = gears.shape.rounded_bar,
    color            = "#efefef",
    background_color = "#000000",
    max_value        = 100,
    value            = 0
}

local w_brightness_icon      = wibox.widget {
    -- TODO
    -- поменять иконку
    -- добавить % яркости
    image  = resources.widgets.memory,
    widget = wibox.widget.imagebox
}

local hide_brightness_adjust = gears.timer {
    timeout   = 3,
    autostart = true,
    callback  = function()
        brightness_adjust.visible = false
    end
}

awful.spawn.easy_async_with_shell(
        max_bright,
        function(stdout)
            w_brightness_bar.max_value = tonumber(stdout)
        end,
        false
)

function brightness:on_brightness()
    awful.spawn.easy_async_with_shell(
            current,
            function(stdout)
                w_brightness_bar.value = tonumber(stdout)
            end,
            false
    )
end

awesome.connect_signal("brightness_change",
                            function(stdout)
                                if (stdout == "+") then
                                    awful.spawn("sudo brightness +25", false)
                                elseif (stdout == "-") then
                                    awful.spawn("sudo brightness -25", false)
                                end

                                if brightness_adjust.visible then
                                    hide_brightness_adjust:again()
                                else
                                    brightness_adjust.visible = true
                                    hide_brightness_adjust:start()
                                    hide_brightness_adjust:again()
                                end

                                brightness:on_brightness()
                            end
)

function brightness:init()
    local offsetx     = 48
    local offsety     = 300

    brightness_adjust = wibox({
                                  x       = capi.wmapi:primary() * capi.wmapi:screenWidth() - offsetx,
                                  y       = capi.wmapi:screenHeight() / 2 - offsety / 2,

                                  width   = offsetx,
                                  height  = offsety,

                                  shape   = gears.shape.rounded_rect,
                                  visible = false,
                                  ontop   = true
                              })

    brightness_adjust:setup {
        layout = wibox.layout.align.vertical,
        {
            wibox.container.margin(
                    w_brightness_bar, 14, 20, 20, 20
            ),
            forced_height = 300 * 0.75,
            direction     = "east",
            layout        = wibox.container.rotate,
        },
        wibox.container.margin(
                w_brightness_icon,
                7, 7, 14, 14
        )
    }

    return w_brightness_icon
end

return setmetatable(brightness, { __call = function(_, ...)
    return brightness:init(...)
end })
