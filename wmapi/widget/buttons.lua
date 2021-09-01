local awful   = require("awful")

local buttons = {}

function buttons:init(args)
    local args = args or {}

    if args.widget == nil then
        capi.log:message("Error args.widget = nil")
    else
        args.widget:buttons(
                awful.util.table.join(
                        capi.wmapi:button({
                                              key   = args.key,
                                              event = args.event,
                                              func  = args.func
                                          })
                )
        )
    end
end

return setmetatable(buttons, { __call = function(_, ...)
    return buttons:init(...)
end })
