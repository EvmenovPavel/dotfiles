local wibox  = require("wibox")

local slider = {}

function slider:init(args)
	local ret  = {}

	local args = args or {}

	ret.widget = wibox.widget({
		type   = "slider",
		widget = wibox.widget.slider,
	})

	return ret
end

return slider
