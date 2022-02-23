local funs    = require("functions")

local restart = {}

function init()
    local w = capi.widget.button()

    w:set_text("Restart")
    w:set_key(capi.event.mouse.button_click_left)
    w:set_func(function()
        funs:on_restart()
    end)

    return w:get()
end

return setmetatable(restart, { __call = function(_, ...)
    return init(...)
end })
