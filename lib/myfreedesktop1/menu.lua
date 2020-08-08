local awful_menu  = require("lib.awful.menu")
local menu_widget = {}
local resources   = require("lib.resources")

local items       = {
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

local function worker(args)
    --local args  = args or {}
    --local items = args.items or {}

    local _menu = awful_menu()

    for _, v in ipairs(items) do
        _menu:add(v)
    end

    function menu_widget:toggle()
        _menu:toggle()
    end

    return menu_widget
end

return setmetatable(menu_widget, { __call = function(_, ...)
    return worker()
end })
