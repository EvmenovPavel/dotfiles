local widget  = require("lib.widget")

local restart = {}

function restart:init()
    local w = widget:button()

    w:set_text("Restart")
    w:set_key(mouse.button_click_left)
    w:set_func(function()
        awesome.restart()
    end)

    return w:get()
end

return setmetatable(restart, { __call = function(_, ...)
    return restart:init(...)
end })
