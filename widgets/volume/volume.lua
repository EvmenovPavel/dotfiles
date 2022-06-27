local wibox         = require("wibox")
local awful         = require("awful")
local gears         = require("gears")

local amixer_volume = "amixer -D pulse sget Master | grep 'Left:' | awk -F '[][]' '{print $2}' | sed 's/[^0-9]//g'"
local amixer_active = "amixer -D pulse sget Master | grep 'Left:' | awk -F '[][]' '{print $4}'"

local volume        = {}
local volume_adjust = {}

local w_volume_bar  = wibox.widget {
    widget           = wibox.widget.progressbar,
    shape            = gears.shape.rounded_bar,
    color            = "#efefef",
    background_color = "#000000",
    max_value        = 100,
    value            = 0
}

local w_volume_icon = wmapi:widget():imagebox(resources.widgets.volume.on)

local function on_images()
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

local function on_volume()
    awful.spawn.easy_async_with_shell(
            amixer_volume,
            function(stdout)
                w_volume_bar.value = tonumber(stdout)
                on_images()
            end,
            false
    )
end

local hide_volume_adjust = wmapi:update(
        function()
            volume_adjust.visible = false
        end,
        3)

local function widget_volume_adjust()
    if volume_adjust.visible then
        hide_volume_adjust:again()
    else
        volume_adjust.visible = true
        hide_volume_adjust:again()
    end

    on_volume()
end

awesome.connect_signal("volume_change",
                       function(stdout)
                           if stdout == "+" or stdout == "-" then
                               awful.spawn("amixer -D pulse set Master 5%" .. stdout, false)
                               widget_volume_adjust()
                           elseif stdout == "off" then
                               awful.spawn("amixer -D pulse set Master 1+ toggle", false)
                               widget_volume_adjust()
                           elseif stdout == "disable" then
                               volume_adjust.visible = false
                           end
                       end
)

function volume:init()
    local offsetx           = 48
    local offsety           = 300

    local screen_primary_id = wmapi:screen_primary_id()
    local width             = 0

    if (screen_primary_id == 1) then
        width = wmapi:screen_width(screen_primary_id)
    else
        for i = 1, screen.count() do
            if screen_primary_id == i then
                break
            end

            local s = screen[i]
            width   = width + s.geometry.width
        end
    end

    volume_adjust = wibox({
                              x       = width - offsetx - 100,
                              y       = wmapi:screen_height() / 2 - offsety / 2,

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
                w_volume_icon:get(),
                7, 7, 14, 14
        )
    }

    return w_volume_icon:get()
end

return setmetatable(volume, { __call = function(_, ...)
    return volume:init(...)
end })
