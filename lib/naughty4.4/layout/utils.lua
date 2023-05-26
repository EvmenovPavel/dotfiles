local wibox    = require("wibox")
local cst      = require("lib.naughty.constants")
local button   = require("awful.button")
local util     = require("awful.util")
local gears    = require("gears")
local gfs      = require("gears.filesystem")
local gsurface = require("gears.surface")

local utils    = {}

function utils:create_actions(self, actions, margin, font, s)
	local layout_actions       = wibox.layout.fixed.vertical()
	local actions_total_height = 0
	local actions_max_width    = 0

	for _, action in ipairs(actions) do
		assert(type(action) == "table")
		assert(action.name ~= nil)
		local actiontextbox   = wmapi.widget:textbox()
		local actionmarginbox = wibox.container.margin()
		actionmarginbox:set_margins(margin)
		actionmarginbox:set_widget(actiontextbox)
		actiontextbox:set_valign("middle")
		actiontextbox:set_font(font)
		actiontextbox:set_markup(string.format('☛ <u>%s</u>', action.name))
		-- calculate the height and width
		local w, h              = actiontextbox:get_preferred_size(s)
		local action_height     = h + 2 * margin
		local action_width      = w + 2 * margin

		actionmarginbox.buttons = {
			button({ }, event.mouse.button_click_left, function()
				action:invoke(self)
			end),
			button({ }, event.mouse.button_click_right, function()
				action:invoke(self)
			end),
		}

		layout_actions:add(actionmarginbox)

		actions_total_height = actions_total_height + action_height
		if actions_max_width < action_width then
			actions_max_width = action_width
		end
	end

	return layout_actions, actions_total_height, actions_max_width
end

-- create iconbox
function utils:create_iconbox(self, icon_data, icon_size, icon, size_info)
	local iconbox = nil

	if icon_data then
		-- Is this really an URI instead of a path?
		if type(icon_data) == "string" and string.sub(icon_data, 1, 7) == "file://" then
			icon_data = string.sub(icon_data, 8)
			-- urldecode URI path
			icon_data = string.gsub(icon_data, "%%(%x%x)", function(x)
				return string.char(tonumber(x, 16))
			end)
		end

		-- try to guess icon if the provided one is non-existent/readable
		if type(icon_data) == "string" and not gfs.file_readable(icon_data) then
			icon_data = util.geticonpath(icon_data, cst.config.icon_formats, cst.config.icon_dirs, icon_size) or icon_data
		end

		-- is the icon file readable?
		local had_icon = type(icon_data) == "string"
		icon_data      = gsurface.load_uncached_silently(icon_data)
		if icon_data then
			iconbox = wmapi.widget:imagebox()
		end

		-- if we have an icon, use it
		local function update_icon(icn)
			if icn then
				size_info.icon_w = icn:get_width()
				size_info.icon_h = icn:get_height()

				icn              = icon_data

				iconbox:set_clip_shape(gears.shape.rounded_rect, 9)
				iconbox:set_resize(true)
				iconbox:set_image(icn)
			end
		end

		if icon_data then
			self:connect_signal("property::icon", function()
				update_icon(gsurface.load_uncached_silently(self.icon))
			end)
			update_icon(icon_data)
		elseif had_icon then
			require("gears.debug").print_warning("naughty: failed to load icon " ..
					icon ..
					"(app_name: " .. self.app_name .. ")" ..
					"(title: " .. self.title .. ")")
		end
	end

	return iconbox
end

return utils