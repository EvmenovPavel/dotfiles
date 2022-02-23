local xrandr   = require("modules.foggy.xrandr")

local s_xrandr = {}

function init()
    capi.wmapi:update(function()
        local outputs = xrandr.info().outputs

        local count   = ""
        for name, output in pairs(outputs) do
            if output.connected then
                count = "--on:" .. name .. "\n\t" .. count
            else
                count = "--off:" .. name .. "\n\t" .. count
            end
        end

        --log:debug(count)

        --b:set_text("screens: " .. tostring(count))

        --screen[2]:fake_remove()
        --screen[2]:set_auto_dpi_enabled(1)
        --local str = ">"
        --for i, it in ipairs(monitors) do
        --str = str .. tostring(it.name)
        --end

    end, 10)
end

return setmetatable(s_xrandr, { __call = function(_, ...)
    return init(...)
end })
