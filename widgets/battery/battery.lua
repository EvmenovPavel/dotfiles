local wibox       = require("wibox")
local awful       = require("awful")
local beautiful   = require("beautiful")
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

-- bolt.svg - заряжает
-- full.svg = 100%
-- three-quarters.svg = 60 - 90%
-- half.svg = 40 - 60%
-- quarter.svg = 20 - 30%
-- empty.svg = 0 - 5%
-- slash.svg - отсуствует

function battery:updateWidgetInfo(acpi)
    local bash_acpi_status = "acpi -b | grep '" .. acpi_status[tonumber(acpi)] .. "' | awk '{print $4}' | sed 's/[^0-9]//g'"

    awful.spawn.easy_async_with_shell(bash_acpi_status, function(result)
        local value = tonumber(result)
        local image = ""

        if acpi == 1 then
            if (value >= 0 and value < 14) then
                image = resources.battery.empty
            elseif (value >= 15 and value < 39) then
                image = resources.battery.quarter
            elseif (value >= 40 and value < 59) then
                image = resources.battery.half
            elseif (value >= 60 and value < 79) then
                image = resources.battery.three_quarters
            elseif (value >= 80 and value <= 100) then
                image = resources.battery.full
            end
        elseif acpi == 2 then
            image = resources.battery.bolt
        elseif acpi == 3 then
            image = resources.battery.bolt
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
        return 2
    elseif notify == 3 then
        naughty.notify {
            preset = naughty.config.presets.normal,
            title  = title,
            text   = "Батарея полностью заряжена."
        }
    end
end

function battery:acpi_info(out)
    if out == "DI" then
        return 1
    elseif out == "CH" then
        return 2
    elseif out == "FU" then
        return 3
    end
end

function battery:init()
    local notify           = 0
    local power            = 0

    local bash_acpi_status = [[bash -c "acpi -b | grep 'Battery 1:' | sed -E 's/^.*(Charging|Discharging|Full).*$/\1/;s/Charging/CH/;s/Discharging/DI/;s/Full/FU/'"]]

    capi.wmapi:watch(bash_acpi_status, 2,
                     function(stdout)

                         local out = capi.wmapi:signs(stdout, "")

                         power     = self:acpi_info(out)
                         self:updateWidgetInfo(power)

                         if power == 1 and notify ~= power then
                             self:notify_power(power)
                         elseif power == 2 and notify ~= power then
                             self:notify_power(power)
                         elseif power == 3 and notify ~= power then
                             self:notify_power(power)
                         end

                         notify = power, wTextBox
                     end)

    local wText  = wibox.container.margin(wibox.container.mirror(wTextBox, { horizontal = false }), 2, 2, 2, 2)

    local widget = wibox.widget({
                                    wIconBox,
                                    wTextBox,
                                    --wText,
                                    layout = wibox.layout.align.horizontal
                                })

    return widget
end

return setmetatable(battery, {
    __call = battery.init
})

