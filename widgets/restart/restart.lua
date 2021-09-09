local resources = require("resources")

local restart   = {}

function restart:init()
    --local button = capi.widget:box()
    --button:set_button({
    --                      event = capi.event.mouse.button_click_left,
    --                      func  = function()
    --                          awesome.restart()
    --                      end
    --                  })
    --
    --button:set_icon(resources.path .. "/restart-alert.svg")
    --
    --button:set_text("test")
    --
    --return button:get()

    local checkbox = capi.widget:checkbox()

    return checkbox:get()
end

return setmetatable(restart, { __call = function()
    return restart:init()
end })
