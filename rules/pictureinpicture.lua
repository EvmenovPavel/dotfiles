-- Firefox
local PictureInPicture = {}

local function init()
	return {
		rule       = {
			class = "firefox",
		},
		except     = {
			instance = "Navigator"
		},
		properties = {
			titlebars_enabled = true,
			floating          = true,
			sticky            = true,
			ontop             = true,

			width             = 470,
			height            = 290,
		}
	}
end

return setmetatable(PictureInPicture, { __call = function(_, ...)
	return init(...)
end })
