-- UE4Editor
local UE4Editor = {}

function UE4Editor:init()
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
    return UE4Editor:init(...)
end })