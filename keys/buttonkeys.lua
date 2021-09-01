local gears      = require("gears")
local mouse      = capi.wmapi.event.mouse

local buttonkeys = gears.table.join(
        capi.wmapi:button({
                              event = mouse.button_click_left,
                              func  = function(c)
                                  if c then
                                      c:emit_signal("request::activate", "mouse_click", { raise = true })
                                  end
                              end
                          })
)

return buttonkeys
