local wibar = {}

function wibar:init(theme)
    theme.wr_height   = 27
    theme.wr_position = placement.top
end

return setmetatable(wibar, { __call = function(_, ...)
    return wibar:init(...)
end })