-- Firefox
local PictureInPicture = {}

function init()
    return {
        rule       = {
            class = "Firefox",
        },
        except     = {
            instance = "Navigator"
        },
        properties = {
            titlebars_enabled = true,
            floating          = true,

            width             = 470,
            height            = 290,
        }
    }
end

return setmetatable(PictureInPicture, { __call = function(_, ...)
    return init(...)
end })