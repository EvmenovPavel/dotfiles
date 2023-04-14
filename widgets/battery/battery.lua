local wibox   = require("wibox")

local battery = {}

function battery:state_to_number(state)
	if state == "discharging" then
		return 1
	elseif state == "charging" then
		return 2
	elseif state == "fully-charged" then
		return 3
	end
end

function battery:updateWidgetInfo(state, value)
	local value = tonumber(value:sub(1, -2))
	local image = ""

	if state == 1 then
		if (value >= 1 and value <= 9) then
			image = resources.battery.level_0
		elseif (value >= 10 and value <= 19) then
			image = resources.battery.level_10
		elseif (value >= 20 and value <= 29) then
			image = resources.battery.level_20
		elseif (value >= 30 and value <= 39) then
			image = resources.battery.level_30
		elseif (value >= 40 and value <= 49) then
			image = resources.battery.level_40
		elseif (value >= 50 and value <= 59) then
			image = resources.battery.level_50
		elseif (value >= 60 and value <= 69) then
			image = resources.battery.level_60
		elseif (value >= 70 and value <= 79) then
			image = resources.battery.level_70
		elseif (value >= 80 and value <= 89) then
			image = resources.battery.level_80
		elseif (value >= 90 and value <= 99) then
			image = resources.battery.level_90
		elseif (value == 100) then
			image = resources.battery.level_100
		end
	elseif state == 2 then
		if (value >= 1 and value <= 9) then
			image = resources.battery.level_0_charging
		elseif (value >= 10 and value <= 19) then
			image = resources.battery.level_10_charging
		elseif (value >= 20 and value <= 29) then
			image = resources.battery.level_20_charging
		elseif (value >= 30 and value <= 39) then
			image = resources.battery.level_30_charging
		elseif (value >= 40 and value <= 49) then
			image = resources.battery.level_40_charging
		elseif (value >= 50 and value <= 59) then
			image = resources.battery.level_50_charging
		elseif (value >= 60 and value <= 69) then
			image = resources.battery.level_60_charging
		elseif (value >= 70 and value <= 79) then
			image = resources.battery.level_70_charging
		elseif (value >= 80 and value <= 89) then
			image = resources.battery.level_80_charging
		elseif (value >= 90 and value <= 99) then
			image = resources.battery.level_90_charging
		elseif (value == 100) then
			image = resources.battery.level_100_charging
		end
	elseif state == 3 then
		image = resources.battery.level_100_charged
	end

	return image, " " .. tostring(value) .. "%"
end

function battery:notify_power(notify)
	local msgbox = wmapi.widget:messagebox()

	if notify == 1 then
		msgbox:information("Battery", "Система электропитания", "Питание отключено.")
	elseif notify == 2 then
		msgbox:information("Battery", "Система электропитания", "Питание подключено.")
	elseif notify == 3 then
		msgbox:information("Battery", "Система электропитания", "Батарея полностью заряжена.")
	end
end

--native-path:          BAT0
--vendor:               ASUSTeK
--model:                ASUS Battery
--power supply:         yes
--updated:              Mon 27 Sep 2021 12:19:48 PM EEST (74 seconds ago)
--has history:          yes
--has statistics:       yes
--battery
--present:             yes
--rechargeable:        yes
--state:               charging
--warning-level:       none
--energy:              43.366 Wh
--energy-empty:        0 Wh
--energy-full:         48.494 Wh
--energy-full-design:  51.276 Wh
--energy-rate:         13.224 W
--voltage:             12.476 V
--time to full:        23.3 minutes
--percentage:          89%
--capacity:            94.5745%
--technology:          lithium-ion
--icon-name:          'battery-full-charging-symbolic'

function battery:init()
	local _private    = {}

	_private.notify   = 0
	_private.state    = 0
	_private.value    = 0

	local bash_upower = [[bash -c "upower -i $(upower -e | grep 'BAT')"]]

	local w_imagebox  = wmapi.widget:imagebox()
	local w_textbox   = wmapi.widget:textbox()

	wmapi:watch(bash_upower, 1,
			function(stdout)
				log:info("stdout", stdout)
				local _upower = { buf = {}, swp = {} }

				for line in stdout:gmatch("[^\r\n]+") do
					for k, v in string.gmatch(line, "([%a].+):([%s].+)") do
						k = k:gsub("%s+", "")
						v = v:gsub("^%s+", "")

						if k == "native-path" then
							_upower.buf.native_path = v
						elseif k == "vendor" then
							_upower.buf.vendor = v
						elseif k == "model" then
							_upower.buf.model = v
						elseif k == "powersupply" then
							_upower.buf.powersupply = v
						elseif k == "updated" then
							_upower.buf.updated = v
						elseif k == "hashistory" then
							_upower.buf.hashistory = v
						elseif k == "hasstatistics" then
							_upower.buf.hasstatistics = v
						elseif k == "present" then
							_upower.buf.present = v
						elseif k == "rechargeable" then
							_upower.buf.rechargeable = v
						elseif k == "state" then
							_upower.buf.state = v
						elseif k == "warning-level" then
							_upower.buf.warning_level = v
						elseif k == "energy" then
							_upower.buf.energy = v
						elseif k == "energy-empty" then
							_upower.buf.energy_empty = v
						elseif k == "energy-full" then
							_upower.buf.energy_full = v
						elseif k == "energy-full-design" then
							_upower.buf.energy_full_design = v
						elseif k == "energy-rate" then
							_upower.buf.energy_rate = v
						elseif k == "voltage" then
							_upower.buf.voltage = v
						elseif k == "timetoempty" then
							_upower.buf.timetoempty = v
						elseif k == "percentage" then
							_upower.buf.percentage = v
						elseif k == "capacity" then
							_upower.buf.capacity = v
						elseif k == "technology" then
							_upower.buf.technology = v
						elseif k == "icon-name" then
							_upower.buf.icon_name = v
						end
					end
				end

				--_upower.buf.native_path
				--_upower.buf.vendor
				--_upower.buf.model
				--_upower.buf.powersupply
				--_upower.buf.updated
				--_upower.buf.hashistory
				--_upower.buf.hasstatistics
				--_upower.buf.present
				--_upower.buf.rechargeable
				--_upower.buf.state
				--_upower.buf.warning_level
				--_upower.buf.energy
				--_upower.buf.energy_empty
				--_upower.buf.energy_full
				--_upower.buf.energy_full_design
				--_upower.buf.energy_rate
				--_upower.buf.voltage
				--_upower.buf.timetoempty
				--_upower.buf.percentage
				--_upower.buf.capacity
				--_upower.buf.technology
				--_upower.buf.icon_name

				_private.state     = tonumber(self:state_to_number(_upower.buf.state))
				_private.value     = _upower.buf.percentage

				local image, value = self:updateWidgetInfo(_private.state, _private.value)

				w_imagebox:image(image)
				w_textbox:text(value)

				if _private.state == 1 and _private.notify ~= _private.state then
					self:notify_power(_private.state)
				elseif _private.state == 2 and _private.notify ~= _private.state then
					self:notify_power(_private.state)
				elseif _private.state == 3 and _private.notify ~= _private.state then
					self:notify_power(_private.state)
				end

				_private.notify = _private.state
			end)

	local ret = wibox.widget({
		w_imagebox:get(),
		w_textbox:get(),
		layout = wibox.layout.align.horizontal
	})

	--ret:connect_signal("mouse::leave", function()
	--    --widget.state = ""
	--    --local n = widget:messagebox()
	--    --n:information("1", "2")
	--end)

	return ret
end

return setmetatable(battery, { __call = function(_, ...)
	return battery:init(...)
end })
