local restart = {}

function restart:init()
    local w = wmapi.widget:switch()
    --w:image(resources.battery.caution)

    w:checked(function()
        wmapi.widget:messagebox():information("app", "title", "text")
    end)

    local int = 0
    local str = "restart" .. tostring(int)
    wmapi:update(function()
        int = int + 1
        --local t = w:textbox()

        --str = str .. " " .. tostring(int)
        --t:text(str)
        --w:visible(not w:visible())
    end, 1)

    return w:get()
end

return setmetatable(restart, { __call = function()
    return restart:init()
end })
