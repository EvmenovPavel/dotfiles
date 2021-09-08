local wibox     = require("wibox")
local beautiful = require("beautiful")

local restart   = {}

function restart:init()
    local button = capi.widget:button()
    button:set_button({
                          event = capi.event.mouse.button_click_left,
                          func  = function()
                              awesome.restart()
                          end
                      })

    local image   = capi.widget:imagebox()

    local textbox = capi.widget:textbox()
    textbox:set_text("BBBB1")

    local textbox1 = capi.widget:textbox()
    textbox1:set_text("AAAA1")

    button:set_widget(image, textbox, textbox1)

    return textbox:get()
end

return setmetatable(restart, { __call = function()
    return restart:init()
end })
