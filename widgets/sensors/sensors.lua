local awful        = require("awful")
local wibox        = require("wibox")
local beautiful    = require("beautiful")

local sensors      = {}

local sersors_rows = {
    spacing = 4,
    layout  = wibox.layout.fixed.vertical,
}

local lists        = {
    "Vcore",
    "Vsoc",
    "Tctl",
    "Tdie",
    "Tccd1",
    "Icore",
    "Isoc",
    "vddgfx",
    "fan1",
    "edge",
    "power1"
}

local function init()
    local wTextbox = wmapi:textbox({ forced_width = 62 })
    local wGraph   = wmapi:graph({})
    local popup    = wmapi:popup()

    local bash     = [[bash -c "sensors"]]
    awful.widget.watch(bash, 3,
            function(widget, stdout)
                for i, name in ipairs(lists) do
                    for line in stdout:gmatch("[^\r\n]+") do
                        local str = wmapi:find(line, name)

                        if not wmapi:is_empty(str) then
                            local row = wibox.widget {
                                wmapi:textbox({ markup = name }),
                                wmapi:textbox({ markup = str }),
                                layout = wibox.layout.ratio.horizontal
                            }

                            row:ajust_ratio(2, 0.15, 0.15, 0.7)
                            sersors_rows[i] = row

                            if name == "Tctl" then
                                local s         = str:gsub('[+°C]', '')
                                wTextbox.markup = "Tctl [" .. s .. "]"
                                widget:add_value(s)
                            end

                            popup:setup {
                                {
                                    sersors_rows,
                                    {
                                        orientation   = "horizontal",
                                        forced_height = 15,
                                        color         = beautiful.bg_focus,
                                        widget        = wibox.widget.separator
                                    },
                                    layout = wibox.layout.fixed.vertical,
                                },
                                margins = 8,
                                widget  = wibox.container.margin
                            }
                        end
                    end
                end
            end,
            wGraph
    )

    local wText    = wibox.container.margin(wibox.container.mirror(wTextbox, { horizontal = false }), 2, 2, 2, 2)
    local wSensors = wibox.container.margin(wibox.container.mirror(wGraph, { horizontal = true }), 0, 0, 0, 2)

    local func     = function()
        if popup.visible then
            popup.visible = not popup.visible
        else
            popup:move_next_to(mouse.current_widget_geometry)
        end
    end

    local widget   = wibox.widget {
        wText,
        --wSensors,
        layout = wibox.layout.align.horizontal
    }

    wmapi:buttons({ widget = widget, func = func })

    return widget
end

return setmetatable(sensors, { __call = function(_, ...)
    return init(...)
end })
