local awful     = require("awful")
local wibox     = require("wibox")

local myspotify = {}

function myspotify:create(s)
	if wmapi:is_screen_primary(s) then
		local spotify = awful.wibar({
			ontop        = false,
			stretch      = true,
			position     = "bottom",
			border_width = 0,
			visible      = true,
			height       = 27,
			width        = wmapi:screen_width() - 30,
			screen       = s,
		})

		spotify:setup {
			--self:w_left(s),
			--self:w_middle(s),
			--self:w_right(s),
			layout = wibox.layout.align.vertical,
		}
	end
end

return setmetatable(myspotify, {
	__call = myspotify.create,
})
