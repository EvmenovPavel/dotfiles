-- UE4Editor
local UE4Editor = {}

local function init()
    return {
        rule       = {
            class = "UE4Editor"
        },
        properties = {
            titlebars_enabled = false,
        }
    }
end

return setmetatable(UE4Editor, { __call = function(_, ...)
    return init(...)
end })