-- CopyQ
local RDesktop = {}

local function init()
    return
    {
        rule       = {
            class = "rdesktop"
        },
        properties = {
            titlebars_enabled = true,
        },
        callback   = function(c, startup)
            wmapi:on_maximized(c, startup)
        end
    }
end

return setmetatable(RDesktop, { __call = function(_, ...)
    return init(...)
end })