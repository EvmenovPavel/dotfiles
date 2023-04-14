local wibox               = require("wibox")
local awful               = require("awful")
local gears               = require("gears")

local amixer_volume       = "amixer -D pulse sget Master | grep 'Left:' | awk -F '[][]' '{print $2}' | sed 's/[^0-9]//g'"
local amixer_active       = "amixer -D pulse sget Master | grep 'Left:' | awk -F '[][]' '{print $4}'" -- on/off
local amixer_increase     = "amixer -D pulse set Master 5%"

-- pactl set-sink-mute 0 toggle  # toggle mute, also you have true/false
-- pactl set-sink-volume 0 0     # mute (force)
-- pactl set-sink-volume 0 100%  # max
-- pactl set-sink-volume 0 +5%   # +5% (up)
-- pactl set-sink-volume 0 -5%   # -5% (down)

-- pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,'

local volume_max          = 100
local volume_max_critical = 150
local volume_min          = 0
local volume_increase     = 5

local volume              = {}
local volume_adjust       = {}

local widget_progressbar  = wibox.widget({
	widget           = wibox.widget.progressbar,
	shape            = gears.shape.rounded_bar,
	color            = "#efefef",
	background_color = "#000000",
	max_value        = volume_max,
	value            = volume_min
})

local widget_image        = wmapi.widget:imagebox()
widget_image:set_image(resources.widgets.volume.on)

local function on_images()
	awful.spawn.easy_async_with_shell(
			amixer_active,
			function(stdout)
				if string.sub(stdout, 0, 2) == "on" then
					widget_image:set_image(resources.widgets.volume.on)
				elseif string.sub(stdout, 0, 3) == "off" then
					widget_image:set_image(resources.widgets.volume.off)
				end
			end,
			false
	)
end

local function on_volume()
	awful.spawn.easy_async_with_shell(
			amixer_volume,
			function(stdout)
				widget_progressbar.value = tonumber(stdout)
				on_images()
			end,
			false
	)
end

local volume_test        = 0

local hide_volume_adjust = wmapi:update(function()
	volume_test           = 0
	volume_increase       = 5
	volume_adjust.visible = false
end, 3)

local function widget_volume_adjust()
	if volume_adjust.visible then
		volume_test = volume_test + 1
		hide_volume_adjust:again()
	else
		volume_adjust.visible = true
		hide_volume_adjust:again()
	end

	if (volume_test > 5) then
		volume_increase = 10
	end

	-- если звук достигает до 100% или 0%, то
	-- счетчик сбрасывается

	on_volume()
end

awesome.connect_signal("volume_change",
		function(stdout)
			if stdout == "+" or stdout == "-" then
				local v = string.format("amixer -D pulse set Master %d%s%s", volume_increase, "%", stdout)
				--log:debug(v)
				awful.spawn(v, false)
				widget_volume_adjust()
			elseif stdout == "off" then
				awful.spawn("amixer -D pulse set Master 1+ toggle", false)
				widget_volume_adjust()
			elseif stdout == "disable" then
				volume_adjust.visible = false
			end
		end
)

function volume:init()
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

	volume_adjust = wibox({
		x       = width - offsetx - 100,
		y       = wmapi:screen_height() / 2 - offsety / 2,

		width   = offsetx,
		height  = offsety,

		shape   = gears.shape.rounded_rect,
		visible = false,
		ontop   = true
	})

	volume_adjust:setup {
		layout = wibox.layout.align.vertical,
		{
			wibox.container.margin(
					widget_progressbar, 14, 20, 20, 20
			),
			forced_height = 300 * 0.75,
			direction     = "east",
			layout        = wibox.container.rotate,
		},
		wibox.container.margin(
				widget_image,
				7, 7, 14, 14
		)
	}

	return widget_image
end

return setmetatable(volume, { __call = function(_, ...)
	return volume:init(...)
end })
