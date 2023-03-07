local wibox     = require("lib.wibox")

local signals   = require("device.signals")
local programms = require("device.programms")

return function()
    local icon   = wmapi.widget:imagebox()
    icon:image(resources.widgets.search)

    local search = wibox.widget {
        icon,
        widget = wibox.layout.fixed.horizontal,
    }

    search:connect_signal(signals.button.press,
                          function()
                              on_run(programms.run)
                          end)

    return search
end
