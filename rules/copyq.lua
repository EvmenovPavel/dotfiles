-- CopyQ
local CopyQ = {}

local function init()
    return
    {
        rule       = {
            class = "copyq"
        },
        properties = {
            titlebars_enabled = false,
            floating          = true,

            width             = 470,
            height            = 290,

            callback          = function(c)
                local coords = wmapi:mouse_coords()

                if (coords.y - c.height < 0) then
                    c.x = coords.x
                    c.y = 0
                else
                    c.x = coords.x
                    c.y = coords.y - c.height
                end
            end
        }
    }
end

return setmetatable(CopyQ, { __call = function(_, ...)
    return init(...)
end })