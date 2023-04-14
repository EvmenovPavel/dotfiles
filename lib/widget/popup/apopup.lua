local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")
local awful     = require("awful")
local popup     = {}

local function infobubble(cr, width, height, corner_radius, arrow_size, arrow_position)
	arrow_size     = arrow_size or 10
	corner_radius  = math.min((height - arrow_size) / 2, corner_radius or 3)
	arrow_position = arrow_position or width - 50 or width / 2

	cr:move_to(0, corner_radius + arrow_size)

	-- Top left corner
	cr:arc(corner_radius, corner_radius + arrow_size, (corner_radius), math.pi, 3 * (math.pi / 2))

	-- The arrow triangle (still at the top)
	cr:line_to(arrow_position, arrow_size)
	cr:line_to(arrow_position + arrow_size, 0)
	cr:line_to(arrow_position + 2 * arrow_size, arrow_size)

	-- Complete the rounded rounded rectangle
	cr:arc(width - corner_radius, corner_radius + arrow_size, (corner_radius), 3 * (math.pi / 2), math.pi * 2)
	cr:arc(width - corner_radius, height - (corner_radius), (corner_radius), math.pi * 2, math.pi / 2)
	cr:arc(corner_radius, height - (corner_radius), (corner_radius), math.pi / 2, math.pi)

	-- Close path
	cr:close_path()
end

function popup:init(args)
	local args = args or {}

	local ret  = {}

	ret.widget = awful.popup {
		type          = "popup",

		ontop         = args.ontop or true,
		visible       = args.visible or false,

		shape         = args.shape or infobubble,

		border_width  = args.border_width or 20,
		border_color  = args.border_color or beautiful.bg_normal,
		maximum_width = args.maximum_width or 300,
		--offset        = args.offset or { y = 5 },

		widget        = args.widget or {}
	}

	return ret
end

return popup
