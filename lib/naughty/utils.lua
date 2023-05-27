local wibox    = require("wibox")
local button   = require("awful.button")
local cst      = require("lib.naughty.constants")
local util     = require("awful.util")
local gears    = require("gears")
local gfs      = require("gears.filesystem")
local gsurface = require("gears.surface")
local gtable   = require("gears.table")
local lgi      = require("lgi")
local cairo    = lgi.cairo

local schar    = string.char
local sbyte    = string.byte
local tcat     = table.concat
local tins     = table.insert

local utils    = {}

-- create iconbox
function utils:create_actions(actions, margin, font, s)
	local layout_actions       = wibox.layout.fixed.vertical()
	local actions_total_height = 0
	local actions_max_width    = 0

	for action, callback in pairs(actions) do
		local actiontextbox   = wibox.widget.textbox()
		local actionmarginbox = wibox.container.margin()
		actionmarginbox:set_margins(margin)
		actionmarginbox:set_widget(actiontextbox)
		actiontextbox:set_valign("middle")
		actiontextbox:set_font(font)
		actiontextbox:set_markup(string.format('☛ <u>%s</u>', action))
		-- calculate the height and width
		local w, h          = actiontextbox:get_preferred_size(s)
		local action_height = h + 2 * margin
		local action_width  = w + 2 * margin

		actionmarginbox:buttons(gtable.join(
				button({ }, 1, callback),
				button({ }, 3, callback)
		))
		layout_actions:add(actionmarginbox)

		actions_total_height = actions_total_height + action_height
		if actions_max_width < action_width then
			actions_max_width = action_width
		end
	end

	return layout_actions, actions_total_height, actions_max_width
end

-- create iconbox
function utils:create_iconbox(icon_data, icon_size)
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
				icn = icon_data

				iconbox:set_clip_shape(gears.shape.rounded_rect, 9)
				iconbox:set_resize(true)
				iconbox:set_image(icn)
			end
		end

		if icon_data then
			update_icon(icon_data)
		elseif had_icon then
			require("gears.debug").print_warning("naughty: failed to load icon " ..
					icon_data ..
					"(app_name: " .. self.app_name .. ")" ..
					"(title: " .. self.title .. ")")
		end
	end

	return iconbox
end

function utils:convert_icon(w, h, rowstride, channels, data)
	-- Do the arguments look sane? (e.g. we have enough data)
	local expected_length = rowstride * (h - 1) + w * channels
	if w < 0 or h < 0 or rowstride < 0 or (channels ~= 3 and channels ~= 4) or
			string.len(data) < expected_length then
		w = 0
		h = 0
	end

	local format = cairo.Format[channels == 4 and 'ARGB32' or 'RGB24']

	-- Figure out some stride magic (cairo dictates rowstride)
	local stride = cairo.Format.stride_for_width(format, w)
	local append = schar(0):rep(stride - 4 * w)
	local offset = 0

	-- Now convert each row on its own
	local rows   = {}

	for _ = 1, h do
		local this_row = {}

		for i = 1 + offset, w * channels + offset, channels do
			local R, G, B, A = sbyte(data, i, i + channels - 1)
			tins(this_row, schar(B, G, R, A or 255))
		end

		-- Handle rowstride, offset is stride for the input, append for output
		tins(this_row, append)
		tins(rows, tcat(this_row))

		offset = offset + rowstride
	end

	local pixels = tcat(rows)
	local surf   = cairo.ImageSurface.create_for_data(pixels, format, w, h, stride)

	-- The surface refers to 'pixels', which can be freed by the GC. Thus,
	-- duplicate the surface to create a copy of the data owned by cairo.
	local res    = gsurface.duplicate_surface(surf)
	surf:finish()
	return res
end

return utils