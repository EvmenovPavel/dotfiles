local awful   = require("awful")

local buttons = {}

function buttons:init(args)
    local args = args or {}

    if args.widget == nil then
        capi.log:message("Error args.widget = nil")
    else
        args.widget:buttons(
                awful.util.table.join(
                        awful.button({}, args.event or capi.wmapi.event.mouse.button_click_left,
                                     args.func or function()
                                         capi.log:message("Error args.func = nil")
                                     end)
                )
        )
    end
end

return setmetatable(buttons, { __call = function(_, ...)
    return buttons:init(...)
end })