local wibox       = require("wibox")
local awful       = require("awful")
local resources   = require("resources")

local naughty     = require("naughty")

local battery     = {}

local wIconBox    = wibox.widget {
    image  = resources.battery.bolt,
    widget = wibox.widget.imagebox
}

local wTextBox    = capi.wmapi:textbox {
}

local acpi_status = {
    "Discharging",
    "Charging",
    "Full"
}

function battery:updateWidgetInfo(level_acpi)
    local bash_acpi_status = "acpi -b | grep '" .. acpi_status[tonumber(level_acpi)] .. "' | awk '{print $4}' | sed 's/[^0-9]//g'"

    awful.spawn.easy_async_with_shell(bash_acpi_status, function(result)
        local value = tonumber(result)
        local image = ""

        if level_acpi == 1 then
            if (value >= 1 and value < 9) then
                image = resources.battery.batteryOutline
            elseif (value >= 10 and value < 19) then
                image = resources.battery.battery20
            elseif (value >= 20 and value < 29) then
                image = resources.battery.battery30
            elseif (value >= 30 and value < 39) then
                image = resources.battery.battery40
            elseif (value >= 40 and value < 49) then
                image = resources.battery.battery40
            elseif (value >= 50 and value < 59) then
                image = resources.battery.battery40
            elseif (value >= 60 and value < 69) then
                image = resources.battery.battery40
            elseif (value >= 70 and value < 79) then
                image = resources.battery.battery40
            elseif (value >= 80 and value < 89) then
                image = resources.battery.battery
            elseif (value >= 90 and value < 99) then
                image = resources.battery.battery90
            elseif (value >= 100) then
                image = resources.battery.batteryFull
            end
        elseif level_acpi == 2 then
            if (value >= 0 and value < 10) then
                --image = resources.battery.batteryCharging10

            elseif (value >= 10 and value < 19) then
                image = resources.battery.batteryCharging10
            elseif (value >= 20 and value < 29) then
                image = resources.battery.batteryCharging20
            elseif (value >= 30 and value < 39) then
                image = resources.battery.batteryCharging30
            elseif (value >= 40 and value < 49) then
                image = resources.battery.batteryCharging40
            elseif (value >= 50 and value < 59) then
                image = resources.battery.batteryCharging50
            elseif (value >= 60 and value < 69) then
                image = resources.battery.batteryCharging60
            elseif (value >= 70 and value < 79) then
                image = resources.battery.batteryCharging70
            elseif (value >= 80 and value < 89) then
                image = resources.battery.batteryCharging80
            elseif (value >= 90 and value < 99) then
                image = resources.battery.batteryCharging90
            elseif (value >= 100) then
                image = resources.battery.batteryCharging100
            end
        elseif level_acpi == 3 then
            image = resources.battery.batteryFull
        end

        wIconBox.image  = image
        wTextBox.markup = " " .. tostring(value) .. "%"
    end)
end

function battery:notify_power(notify)
    local title = "Система электропитания"

    if notify == 1 then
        naughty.notify {
            preset = naughty.config.presets.critical,
            title  = title,
            text   = "Питание отключено."
        }
    elseif notify == 2 then
        naughty.notify {
            preset = naughty.config.presets.normal,
            title  = title,
            text   = "Питание подключено."
        }
    elseif notify == 3 then
        naughty.notify {
            preset = naughty.config.presets.normal,
            title  = title,
            text   = "Батарея полностью заряжена."
        }
    end
end

function battery:init()
    local notify           = 0
    local power            = 0

    local bash_acpi_status = [[bash -c "acpi -b | grep 'Battery 1:' | sed -E 's/^.*(Discharging|Charging|Full).*$/\1/;s/Discharging/1/;s/Charging/2/;s/Full/3/'"]]

    capi.wmapi:watch(bash_acpi_status, 2,
                     function(stdout)
                         local out = capi.wmapi:signs(stdout, "")

                         power     = tonumber(out)
                         self:updateWidgetInfo(power)

                         if power == 1 and notify ~= power then
                             self:notify_power(power)
                         elseif power == 2 and notify ~= power then
                             self:notify_power(power)
                         elseif power == 3 and notify ~= power then
                             self:notify_power(power)
                         end

                         notify = power
                     end)

    local widget = wibox.widget({
                                    wIconBox,
                                    wTextBox,
                                    layout = wibox.layout.align.horizontal
                                })

    return widget
end

return setmetatable(battery, {
    __call = battery.init
})

