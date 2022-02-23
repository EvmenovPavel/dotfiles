local wibar = {}

local function init(theme)
    theme.wr_height   = 27
    theme.wr_position = theme.position.top
end

return setmetatable(wibar, { __call = function(_, ...)
    return init(...)
end })