local restart = {}

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
    textbox:set_text("Asdasdasd")

    --button:set_text("111text")
    button:set_widget(image, textbox)

    return button.widget
end

return setmetatable(restart, { __call = function()
    return restart:init()
end })
