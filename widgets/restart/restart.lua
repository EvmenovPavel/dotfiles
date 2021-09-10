local resources = require("resources")

local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local restart   = {}

function restart:init()
    --local button = capi.widget:button()
    --button:set_button({
    --                      event = capi.event.mouse.button_click_left,
    --                      func  = function()
    --                          awesome.restart()
    --                      end
    --                  })
    --
    --button:set_image(resources.path .. "/restart-alert.svg")
    --
    --button:set_style()
    --
    --button:set_text("test")
    --
    --return button:get()

    local checkbox = capi.widget:checkbox()
    return checkbox:get()

    --local switch = capi.widget:switch()
    --return switch:get()
end

return setmetatable(restart, { __call = function()
    return restart:init()
end })
