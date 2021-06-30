local beautiful = require("lib.beautiful")
local wibox     = require("lib.wibox")

local wmapi     = require("wmapi")
local timer     = wmapi.timer
local markup    = wmapi.markup
local resources = require("resources")
local config    = require("config")

local function pathtotable(dir)
    return setmetatable({ _path = dir },
                        { __index = function(self, index)
                            local path = self._path .. '/' .. index
                            local f    = io.open(path)
                            if f then
                                local s = f:read("*all")
                                f:close()
                                if s then
                                    return s
                                else
                                    local o = { _path = path }
                                    setmetatable(o, getmetatable(self))
                                    return o
                                end
                            end
                        end
                        })
end

local function coretempinfo(warg)
    if not warg then
        return
    end

    local zone     = { -- Known temperature data sources
        ["sys"]   = { "/sys/class/thermal/", file = "temp", div = 1000 },
        ["core"]  = { "/sys/devices/platform/", file = "temp2_input", div = 1000 },
        ["hwmon"] = { "/sys/class/hwmon/", file = "temp1_input", div = 1000 },
        ["proc"]  = { "/proc/acpi/thermal_zone/", file = "temperature" }
    } --  Default to /sys/class/thermal
    warg           = type(warg) == "table" and warg or { warg, "sys" }

    -- Get temperature from thermal zone
    local _thermal = pathtotable(zone[warg[2]][1] .. warg[1])

    local data     = warg[3] and _thermal[warg[3]] or _thermal[zone[warg[2]].file]
    if data then
        if zone[warg[2]].div then
            return { math.floor(data / zone[warg[2]].div) }
        else
            -- /proc/acpi "temperature: N C"
            return { tonumber(string.match(data, "[%d]+")) }
        end
    end

    return { 0 }
end

local usage = 0

return function()
    local widget = wmapi:textbox()
    timer:create(widget,
                 function()
                     usage = coretempinfo("thermal_zone0")[1]
                     return markup.font(config.font, markup.fg.color(beautiful.colors.widget.fg_widget, usage .. "%"))
                 end, 1)

    local icon = wmapi.imagebox()
    timer:create(icon,
                 function()
                     if usage >= 0 and usage < 20 then
                         return resources.widgets.coretemp.veryLow
                     elseif usage >= 20 and usage < 40 then
                         return resources.widgets.coretemp.belowAverage
                     elseif usage >= 40 and usage < 60 then
                         return resources.widgets.coretemp.average
                     elseif usage >= 60 and usage < 80 then
                         return resources.widgets.coretemp.aboveAverage
                     elseif usage >= 80 and usage < 100 then
                         return resources.widgets.coretemp.veryHigh
                     end
                 end, 1)

    local coretemp = wibox.widget({
                                      icon,
                                      wmapi:pad(2),
                                      widget,
                                      widget = wibox.layout.fixed.horizontal,
                                  })

    return coretemp
end