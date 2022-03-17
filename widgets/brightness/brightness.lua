local wibox                  = require("wibox")
local awful                  = require("awful")
local gears                  = require("gears")

local current                = "sudo brightness -s | grep 'current_bright:' | awk -F '[][]' '{print $1}' | sed 's/[^0-9]//g'"
local max_bright             = "sudo brightness -s | grep 'max_bright:' | awk -F '[][]' '{print $1}' | sed 's/[^0-9]//g'"

local brightness             = {}
local brightness_adjust      = {}

--
local brightness_dir         = ""
local brightness_current     = 0
local brightness_max         = 0
local brightness_value       = 0

local w_brightness_bar       = wibox.widget {
    widget           = wibox.widget.progressbar,
    shape            = gears.shape.rounded_bar,
    color            = "#efefef",
    background_color = "#000000",
    max_value        = 100,
    value            = 0
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

function brightness:widget_brightness_adjust()
    if brightness_adjust.visible then
        hide_brightness_adjust:again()
    else
        brightness_adjust.visible = true
        hide_brightness_adjust:start()
        hide_brightness_adjust:again()
    end

    --local value            = w_brightness_bar.value
    --w_brightness_bar.value = tonumber(value) .. math.modf(tostring(brightness_value))
end

awesome.connect_signal("brightness_change",
                       function(stdout)
                           if ((stdout == "+") or (stdout == "-")) then
                               awful.spawn("sudo brightness " .. stdout .. math.modf(tostring(brightness_value)), false)
                               --brightness:update_brightness_value()
                               --wmapi:sleep(0.2)
                               brightness:widget_brightness_adjust()
                           elseif (stdout == "disable") then
                               brightness_adjust.visible = false
                           end
                       end
)

function brightness:get_current_dir()
    local dir_intel = "/sys/class/backlight/intel_backlight"
    local dir_amd   = "/sys/class/backlight/amdgpu_bl0"

    if (not wmapi:is_dir(dir_amd)) then
        brightness_dir = dir_amd;
    elseif (not wmapi:is_dir(dir_intel)) then
        brightness_dir = dir_intel
    else
        log:debug("Error: не найдена папка ни intel_backlight и amdgpu_bl0")
        return true
    end

    return false
end

function brightness:update_brightness_value()
    brightness_current = wmapi:read_file(brightness_dir .. "/brightness")
    if (brightness_current == nil) then
        return true
    end
    brightness_current = tonumber(brightness_current)

    brightness_max     = wmapi:read_file(brightness_dir .. "/max_brightness")
    if (brightness_max == nil) then
        return true
    end
    brightness_max         = tonumber(brightness_max)

    brightness_value       = tonumber(brightness_max) / 10

    w_brightness_bar.value = brightness_current

    return false
end

function brightness:init()
    if (self:get_current_dir()) then
        return
    end

    if (self:update_brightness_value()) then
        return
    end

    wmapi:update(function()
        self:update_brightness_value()
    end, 0.2)

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

    brightness_adjust = wibox({
                                  x       = width - offsetx - 10,
                                  y       = wmapi:screen_height() / 2 - offsety / 2,

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
            forced_height = offsety * 0.75,
            direction     = "east",
            layout        = wibox.container.rotate,
        },
    }
end

return setmetatable(brightness, { __call = function(_, ...)
    return brightness:init(...)
end })
