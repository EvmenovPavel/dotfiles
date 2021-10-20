local restart       = {}

function restart:init()
    local s = capi.widget:button(
            {
                func = function()
                    awesome.restart()
                end
            }
    )

    return s:get()
end

return setmetatable(restart, { __call = function()
    return restart:init()
end })
