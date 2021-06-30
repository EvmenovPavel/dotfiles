local wibox       = require("lib.wibox")

local wmapi       = require("wmapi")
local resources   = require("resources")
local signals     = require("device.signals")
local quitmenu    = require("widgets.quitmenu")
local awful_menu  = require("lib.awful.menu")

local menu_widget = {}

local function menu()
    local _menu = awful_menu()

    local items = {
        {
            "Chromium",
            "chromium-browser",
            resources.widgets.memory
        },
        {
            "Dropbox",
            "dropbox",
            resources.widgets.memory
        }
    }

    for _, v in ipairs(items) do
        _menu:add(v)
    end

    function menu_widget:toggle()
        _menu:toggle()
    end

    return _menu
end

return function()
    --menu()

    local icon   = wmapi:imagebox(resources.widgets.power)

    local widget = wibox.widget({
                                    icon,
                                    layout = wibox.layout.fixed.horizontal,
                                })

    local cw     = quitmenu()
    widget:connect_signal(signals.button.press,
                          function()
                              cw:show()
                              --menu_widget:toggle()
                          end)

    --widget:emit_signal("Esc",
    --                      function()
    --                          cw:show()
    --                          --menu_widget:toggle()
    --                      end)

    return widget
end
