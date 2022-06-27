local restart = {}

function restart:init()
    local w    = wmapi:widget():prompt()

    --w:run()
    local test = true

    w:connect_signal(
            event.signals.button.release,
            function(_, _, _, b)
                if b == event.mouse.button_click_left then
                    test = not test

                    if test then
                        w:focus()
                    else
                        w:unfocus()
                    end
                end
            end
    )

    return w

    --local w = wmapi:widget():switch()

    --w:set_text("Restart")
    --w:set_event(event.mouse.button_click_left)
    --w:set_function(
    --        function()
    --            log:debug("trigger")
    --        end)
    --w:trigger(true)
    --return w:get()
end

return setmetatable(restart, { __call = function(_, ...)
    return restart:init(...)
end })
