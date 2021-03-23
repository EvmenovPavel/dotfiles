local wibox     = require("wibox")
local awful     = require("awful")
local beautiful = require("beautiful")

local naughty   = require("naughty")

local memory    = {}

function row(name, str)
    local row = wibox.widget {
        capi.wmapi:textbox({ markup = name }),
        capi.wmapi:textbox({ markup = str }),
        layout = wibox.layout.ratio.horizontal
    }

    row:ajust_ratio(2, 0.15, 0.15, 0.7)

    return row
end

function memory:init()
    local wTextbox = capi.wmapi:textbox({ forced_width = 60 })
    local popup    = capi.wmapi:popup()

    local notify   = false

    local bash     = [[bash -c "/etc/acpi/power.sh"]]

    awful.widget.watch(bash, 2,
                       function(widget, stdout)
                           if capi.wmapi:sub(stdout, 2) == "on" then
                               power = true
                           elseif capi.wmapi:sub(stdout, 3) == "off" then
                               power = false
                           end

                           if power == true and notify == false then
                               notify = true

                               naughty.notify {
                                   preset = naughty.config.presets.normal,
                                   title  = "Система электропитания",
                                   text   = "Питание подключено." }
                           elseif power == false and notify == true then
                               notify = false

                               naughty.notify {
                                   preset = naughty.config.presets.critical,
                                   title  = "Система электропитания",
                                   text   = "Питание отключено." }
                           end
                       end,
                       wTextbox
    )

    local wText  = wibox.container.margin(wibox.container.mirror(wTextbox, { horizontal = false }), 2, 2, 2, 2)

    local widget = wibox.widget({
                                    wText,
                                    layout = wibox.layout.align.horizontal
                                })

    local func   = function()
        if popup.visible then
            popup.visible = not popup.visible
        else
            popup:move_next_to(capi.mouse.current_widget_geometry)
        end
    end

    capi.wmapi:buttons({ widget = widget, func = func })

    return widget
end

return setmetatable(memory, {
    __call = memory.init
})

