local wibox               = require("wibox")
local awful               = require("awful")
local gears               = require("gears")

local brightness          = {}
local brightness_adjust   = {}

local brightness_current  = 0
local brightness_max      = 1.0
local brightness_min      = 0.3
local brightness_increase = 0.02

local w_brightness_bar    = wibox.widget {
	widget           = wibox.widget.progressbar,
	shape            = gears.shape.rounded_bar,
	color            = "#efefef",
	background_color = "#000000",
	max_value        = brightness_max - brightness_min,
	value            = 0
}

local w_volume_icon       = wmapi.widget:imagebox()
w_volume_icon:set_image(resources.widgets.volume.on)
local hide_brightness_adjust = wmapi:update(function()
	brightness_adjust.visible = false
end, 3)

function brightness:update_widget()
	if (brightness_current > brightness_max) then
		brightness_current = brightness_max
	elseif (brightness_current < brightness_min) then
		brightness_current = brightness_min
	end

	w_brightness_bar.value = brightness_current - brightness_min
end

function brightness:widget_brightness_adjust()
	if brightness_adjust.visible then
		hide_brightness_adjust:again()
	else
		brightness_adjust.visible = true
		hide_brightness_adjust:start()
		hide_brightness_adjust:again()
	end
end

function brightness:set_brightness(name, value)
	local command = string.format("xrandr --output %s --brightness %s", name, tostring(value))
	awful.spawn(command, false)
end

awesome.connect_signal("brightness_change",
		function(stdout)
			if ((stdout == "+") or (stdout == "-")) then
				if (stdout == "+") then
					brightness_current = brightness_current + brightness_increase
				elseif (stdout == "-") then
					brightness_current = brightness_current - brightness_increase
				end

				brightness:update_widget()
				brightness:set_brightness("eDP", brightness_current)
				brightness:widget_brightness_adjust()
			elseif (stdout == "disable") then
				brightness_adjust.visible = false
			end
		end
)

function brightness:init()
	local command = [[bash -c "xrandr --verbose | awk '/Brightness/ { print $2; exit }'"]]
	wmapi:watch(command, 1, function(stdout)
		brightness_current = tonumber(stdout)
		--brightness:update_widget()
	end)

	local offsetx           = 48
	local offsety           = 300

	local screen_primary_id = wmapi:screen_primary_id()
	local width             = 0

	if (screen_primary_id == 1) then
		width = wmapi:screen_width(screen_primary_id)
	else
		for i = 1, screen.count() do
			if screen_primary_id == i then
				break
			end

			local s = screen[i]
			width   = width + s.geometry.width
		end
	end

	brightness_adjust = wibox({
		x       = width - offsetx - 10,
		y       = wmapi:screen_height() / 2 - offsety / 2,

		width   = offsetx,
		height  = offsety,

		shape   = gears.shape.rounded_rect,
		visible = false,
		ontop   = true
	})

	brightness_adjust:setup({
		layout = wibox.layout.align.vertical,
		{
			wibox.container.margin(
					w_brightness_bar, 14, 20, 20, 20
			),
			forced_height = offsety * 0.75,
			direction     = "east",
			layout        = wibox.container.rotate,
		},
		wibox.container.margin(
				w_volume_icon,
				7, 7, 14, 14
		)
	})
end

return setmetatable(brightness, { __call = function(_, ...)
	return brightness:init(...)
end })
