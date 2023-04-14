----------------------------------------------------------------------------
--- A notification popup widget (deprecated implementation).
--
-- This is the legacy notification widget. It was the default until Awesome
-- v4.3 but is now being deprecated in favor of a more flexible widget.
--
-- The reason for this is/was that this widget is inflexible and mutate the
-- state of the notification object in a way that hinder other notification
-- widgets.
--
-- If no other notification widget is specified, Awesome fallback to this
-- widget.
--
--@DOC_naughty_actions_EXAMPLE@
--
-- Use the `naughty.notification.position` property to control where the popup
-- is located.
--
--@DOC_awful_notification_corner_EXAMPLE@
--
-- @author koniu &lt;gkusnierz@gmail.com&gt;
-- @author Emmanuel Lepage Vallee &lt;elv1313@gmail.com&gt;
-- @copyright 2008 koniu
-- @copyright 2017 Emmanuel Lepage Vallee
-- @popupmod naughty.layout.legacy
----------------------------------------------------------------------------

local capi         = { screen = screen, awesome = awesome }
local naughty      = require("lib.naughty.core")
local screen       = require("awful.screen")
local button       = require("awful.button")
local beautiful    = require("beautiful")
local surface      = require("gears.surface")
local wibox        = require("wibox")
local gfs          = require("gears.filesystem")
local gtable       = require("gears.table")
local timer        = require("gears.timer")
local gmath        = require("gears.math")
local gears        = require("gears")
local cairo        = require("lgi").cairo
local util         = require("awful.util")

local properties   = {
	"app_name", "title", "message"
}

local TEXTBOX_NAME = "textbox_"

local function get_screen(s)
	return s and capi.screen[s]
end

-- This is a copy of the table found in `naughty.core`. The reason the copy
-- exists is to make sure there is only unidirectional coupling between the
-- legacy widget (this class) and `naughty.core`. Exposing the "raw"
-- notification list is also a bad design and might cause indices and position
-- corruption. While it cannot be removed from the public API (yet), it can at
-- least be blacklisted internally.
local current_notifications = setmetatable({}, { __mode = "k" })

screen.connect_for_each_screen(function(s)
	current_notifications[s] = {
		top_left      = {},
		top_middle    = {},
		top_right     = {},
		bottom_left   = {},
		bottom_middle = {},
		bottom_right  = {},
		middle        = {},
	}
end)

capi.screen.connect_signal("removed", function(s)
	timer.delayed_call(function()
		current_notifications[s] = nil
	end)
end)

--- Sum heights of notifications at position
--
-- @param s Screen to use
-- @param position top_right | top_left | bottom_right | bottom_left
--   | top_middle | bottom_middle | middle
-- @param[opt] idx Index of last notification
-- @return Height of notification stack with spacing
local function get_total_heights(s, position, idx)
	local sum           = 0
	local notifications = current_notifications[s][position]
	idx                 = idx or #notifications
	for i = 1, idx, 1 do
		local n = notifications[i]

		-- `n` will not nil when there is too many notifications to fit in `s`
		if n then
			sum = sum + n.height + naughty.config.spacing
		end
	end
	return sum
end

--- Evaluate desired position of the notification by index - internal
--
-- @param s Screen to use
-- @param position top_right | top_left | bottom_right | bottom_left
--   | top_middle | bottom_middle | middle
-- @param idx Index of the notification
-- @param[opt] width Popup width.
-- @param height Popup height
-- @return Absolute position and index in { x = X, y = Y, idx = I } table
local function get_offset(s, position, idx, width, height)
	s        = get_screen(s)
	local ws = s.workarea
	local v  = {}
	idx      = idx or #current_notifications[s][position] + 1
	width    = width or current_notifications[s][position][idx].width

	-- calculate x
	if position:match("left") then
		v.x = ws.x + naughty.config.padding
	elseif position:match("middle") then
		v.x = ws.x + (ws.width / 2) - (width / 2)
	else
		v.x = ws.x + ws.width - (width + naughty.config.padding)
	end

	-- calculate existing popups' height
	local existing = get_total_heights(s, position, idx - 1)

	-- calculate y
	if position:match("top") then
		v.y = ws.y + naughty.config.padding + existing
	elseif position:match("bottom") then
		v.y = ws.y + ws.height - (naughty.config.padding + height + existing)
	else
		local total = get_total_heights(s, position)
		v.y         = ws.y + (ws.height - total) / 2 + naughty.config.padding + existing
	end

	-- Find old notification to replace in case there is not enough room.
	-- This tries to skip permanent notifications (without a timeout),
	-- e.g. critical ones.
	local find_old_to_replace = function()
		for i = 1, idx - 1 do
			local n = current_notifications[s][position][i]
			if n and n.timeout > 0 then
				return n
			end
		end
		-- Fallback to first one.
		return current_notifications[s][position][1]
	end

	-- if positioned outside workarea, destroy oldest popup and recalculate
	if v.y + height > ws.y + ws.height or v.y < ws.y then
		local n = find_old_to_replace()
		if n then
			n:destroy(naughty.notification_closed_reason.too_many_on_screen)
		end
		v = get_offset(s, position, idx, width, height)
	end

	return v
end

--- Re-arrange notifications according to their position and index - internal
--
-- @return None
local function arrange(s)
	-- {} in case the screen has been deleted
	for p in pairs(current_notifications[s] or {}) do
		for i, notification in pairs(current_notifications[s][p]) do
			local offset = get_offset(s, p, i, notification.width, notification.height)
			notification.box:geometry({ x = offset.x, y = offset.y })
		end
	end
end

local function update_size(self)
	local s      = self.size_info
	local width  = s.width
	local height = s.height
	local margin = s.margin

	-- calculate the width
	if not width then
		local numbers = {}

		for _, prop in ipairs(properties) do
			local w, _ = self[TEXTBOX_NAME .. prop]:get_preferred_size(self.screen)
			table.insert(numbers, w)
		end

		-- Найти наибольшее число в массиве
		local w = math.max(table.unpack(numbers))
		width   = w + (self.iconbox and s.icon_w + 2 * margin or 0) + 2 * margin
	end

	if width < s.actions_max_width then
		width = s.actions_max_width
	end

	if s.max_width then
		width = math.min(width, s.max_width)
	end


	-- calculate the height
	if not height then
		local w = width - (self.iconbox and s.icon_w + 2 * margin or 0) - 2 * margin

		local h = 0
		for _, prop in ipairs(properties) do
			h = h + self[TEXTBOX_NAME .. prop]:get_height_for_width(w, self.screen)
		end

		if self.iconbox and s.icon_h + 2 * margin > h + 2 * margin then
			height = s.icon_h + 2 * margin
		else
			height = h + 2 * margin
		end
	end

	height = height + s.actions_total_height

	if s.max_height then
		height = math.min(height, s.max_height)
	end

	-- crop to workarea size if too big
	local workarea     = self.screen.workarea
	local border_width = s.border_width or 0
	local padding      = naughty.config.padding or 0
	if width > workarea.width - 2 * border_width - 2 * padding then
		width = workarea.width - 2 * border_width - 2 * padding
	end
	if height > workarea.height - 2 * border_width - 2 * padding then
		height = workarea.height - 2 * border_width - 2 * padding
	end

	-- set size in notification object
	self.height  = height + 2 * border_width
	self.width   = width + 2 * border_width
	local offset = get_offset(self.screen, self.position, self.idx, self.width, self.height)
	self.box:geometry({
		width  = width,
		height = height,
		x      = offset.x,
		y      = offset.y,
	})

	-- update positions of other notifications
	arrange(self.screen)
end

local function seek_and_destroy(n)
	for _, positions in pairs(current_notifications) do
		for _, pos in pairs(positions) do
			for k, n2 in ipairs(pos) do
				if n == n2 then
					table.remove(pos, k)
					return
				end
			end
		end
	end
end

local function cleanup(self, _ --[[reason]], keep_visible)
	-- It is not a legacy notification
	if not self.box then
		return
	end

	local scr = self.screen

	-- Brute force find it, the position could have been replaced.
	seek_and_destroy(self)

	if (not keep_visible) or (not scr) then
		self.box.visible = false
	end

	arrange(scr)
end

naughty.connect_signal("destroyed", cleanup)

-- Don't copy paste the list of fallback, it is hard to spot mistakes.
local function get_value(notification, args, preset, prop)
	return notification[prop] -- set by the rules
			or args[prop] -- magic and undocumented, but used by the legacy API
			or preset[prop] --deprecated
			or beautiful["notification_" .. prop] -- from the theme
end

function naughty.default_notification_handler(notification, args)
	-- This is a fallback for users whose config doesn't have the newer
	-- `request::display` section.
	if naughty.has_display_handler and not notification._private.widget_template_failed then
		return
	end

	-- If request::display is called more than once, simply make sure the wibox
	-- is visible.
	if notification.box then
		notification.box.visible = true
		return
	end

	local preset   = notification.preset or {}

	local app_name = get_value(notification, args, preset, "app_name")
	local title    = get_value(notification, args, preset, "title")
	local message  = get_value(notification, args, preset, "message") or args.text or preset.text

	local s        = get_screen(
			get_value(notification, args, preset, "screen") or screen.focused()
	)

	if not s then
		local err = "lib.naughty.notify: there is no screen available to display the following notification:"
		err       = string.format("%s app_name='%s' title='%s' text='%s'", err, tostring(app_name or ""), tostring(title or ""), tostring(message or ""))
		require("gears.debug").print_warning(err)
		return
	end

	local timeout           = get_value(notification, args, preset, "timeout")
	local app_icon          = get_value(notification, args, preset, "icon")
	local icon_size         = get_value(notification, args, preset, "icon_size")
	local ontop             = get_value(notification, args, preset, "ontop")
	local hover_timeout     = get_value(notification, args, preset, "hover_timeout")
	local position          = get_value(notification, args, preset, "position")

	local actions           = notification.actions or args.actions
	local destroy_cb        = args.destroy

	-- beautiful
	local font              = get_value(notification, args, preset, "font")
			or beautiful.font or capi.awesome.font

	local fg                = get_value(notification, args, preset, "fg")
			or beautiful.fg_normal or '#ffffff'

	local bg                = get_value(notification, args, preset, "bg")
			or beautiful.bg_normal or '#535d6c'

	local border_color      = get_value(notification, args, preset, "border_color")
			or beautiful.bg_focus or '#535d6c'

	local border_width      = get_value(notification, args, preset, "border_width")
	local shape             = get_value(notification, args, preset, "shape")
	local width             = get_value(notification, args, preset, "width")
	local height            = get_value(notification, args, preset, "height")
	local max_width         = get_value(notification, args, preset, "max_width")
	local max_height        = get_value(notification, args, preset, "max_height")
	local margin            = get_value(notification, args, preset, "margin")
	local opacity           = get_value(notification, args, preset, "opacity")

	notification.screen     = s
	notification.destroy_cb = destroy_cb
	notification.timeout    = timeout
	notification.position   = position

	-- hook destroy
	notification.timeout    = timeout
	local die               = notification.die

	local run               = function()
		if args.run then
			args.run(notification)
		else
			die(naughty.notification_closed_reason.dismissed_by_user)
		end
	end

	local hover_destroy     = function()
		if hover_timeout == 0 then
			die(naughty.notification_closed_reason.expired)
		else
			if notification.timer then
				notification.timer:stop()
			end
			notification.timer = timer { timeout = hover_timeout }
			notification.timer:connect_signal("timeout", function()
				die(naughty.notification_closed_reason.expired)
			end)
			notification.timer:start()
		end
	end

	-- create textbox
	local function create_textbox(self, prop)
		local textbox = wibox.widget.textbox()
		textbox:set_valign("middle")
		textbox:set_font(font)
		textbox:set_text(self[prop])

		self[TEXTBOX_NAME .. prop] = textbox
	end

	for _, prop in ipairs(properties) do
		create_textbox(notification, prop)
	end

	local function update_textbox(self, _1, _2)
		log:info(">> update_textbox:", _1, _2)
		if not self.box then
			return
		end

		--local app_name = self.app_name or ""
		--local message  = self.message or ""
		--message        = wmapi:sublen(message, 30)
		--local title    = self.title or ""
		--local textbox  = self.textbox
	end

	-- Update the content if it changes
	notification:connect_signal("property::app_name", update_textbox)
	notification:connect_signal("property::message", update_textbox)
	notification:connect_signal("property::title", update_textbox)

	local layout_actions       = wibox.layout.fixed.vertical()
	local layout_top           = wibox.layout.fixed.horizontal()
	local layout_middle        = wibox.layout.fixed.vertical()

	local actions_max_width    = 0
	local actions_total_height = 0
	if actions then
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
					action:invoke(notification)
				end),
				button({ }, event.mouse.button_click_right, function()
					action:invoke(notification)
				end),
			}

			layout_actions:add(actionmarginbox)

			actions_total_height = actions_total_height + action_height
			if actions_max_width < action_width then
				actions_max_width = action_width
			end
		end
	end

	local size_info        = {
		width                = width,
		height               = height,
		max_width            = max_width,
		max_height           = max_height,
		margin               = margin,
		border_width         = border_width,
		actions_max_width    = actions_max_width,
		actions_total_height = actions_total_height,
	}

	-- create iconbox
	local app_iconbox      = nil
	local centered_iconbox = nil

	if app_icon then
		-- Is this really an URI instead of a path?
		if type(app_icon) == "string" and string.sub(app_icon, 1, 7) == "file://" then
			app_icon = string.sub(app_icon, 8)
			-- urldecode URI path
			app_icon = string.gsub(app_icon, "%%(%x%x)", function(x)
				return string.char(tonumber(x, 16))
			end)
		end

		-- try to guess icon if the provided one is non-existent/readable
		if type(app_icon) == "string" and not gfs.file_readable(app_icon) then
			app_icon = util.geticonpath(app_icon, naughty.config.icon_formats, naughty.config.icon_dirs, icon_size) or app_icon
		end

		-- is the icon file readable?
		local had_icon = type(app_icon) == "string"
		app_icon       = surface.load_uncached_silently(app_icon)
		if app_icon then
			app_iconbox      = wmapi.widget:imagebox()
			-- Создать контейнер и выровнять по центру
			centered_iconbox = wibox.container.place(app_iconbox, { halign = "center", valign = "center" })
		end

		-- if we have an icon, use it
		local function update_icon(icn)
			if icn then
				if max_height and icn:get_height() > max_height then
					icon_size = icon_size and math.min(max_height, icon_size) or max_height
				end

				if max_width and icn:get_width() > max_width then
					icon_size = icon_size and math.min(max_width, icon_size) or max_width
				end

				if icon_size and (icn:get_height() > icon_size or icn:get_width() > icon_size) then
					size_info.icon_scale_factor = icon_size / math.max(icn:get_height(),
							icn:get_width())

					size_info.icon_w            = icn:get_width() * size_info.icon_scale_factor
					size_info.icon_h            = icn:get_height() * size_info.icon_scale_factor

					local scaled                = cairo.ImageSurface(cairo.Format.ARGB32,
							gmath.round(size_info.icon_w),
							gmath.round(size_info.icon_h))

					local cr                    = cairo.Context(scaled)
					cr:scale(size_info.icon_scale_factor, size_info.icon_scale_factor)
					cr:set_source_surface(icn, 0, 0)
					cr:paint()
					icn = scaled
				else
					size_info.icon_w = icn:get_width()
					size_info.icon_h = icn:get_height()
				end

				app_iconbox:set_resize(true)
				app_iconbox:set_image(icn)

				-- Установить новый размер
				centered_iconbox.forced_width  = size_info.icon_w
				centered_iconbox.forced_height = size_info.icon_h
			end
		end

		if app_icon then
			notification:connect_signal("property::icon", function()
				update_icon(surface.load_uncached_silently(notification.icon))
			end)
			update_icon(app_icon)
		elseif had_icon then
			require("gears.debug").print_warning("naughty: failed to load icon " ..
					(args.icon or preset.icon) ..
					"(app_name: " .. app_name .. ")" ..
					"(title: " .. title .. ")")
		end

	end

	notification.iconbox = app_iconbox

	-- create container wibox
	if not notification.reuse_box then
		notification.box = wibox({ fg                 = fg,
		                           bg                 = bg,
		                           border_color       = border_color,
		                           border_width       = border_width,
		                           shape_border_color = shape and border_color,
		                           shape_border_width = shape and border_width,
		                           shape              = function(cr, width, height)
			                           gears.shape.rounded_rect(cr, width, height, 10)
		                           end,
		                           type               = "notification" })
	else
		notification.box = notification.reuse_box
	end

	if hover_timeout then
		notification.box:connect_signal("mouse::enter", hover_destroy)
	end

	notification.size_info = size_info

	-- position the wibox
	update_size(notification)
	notification.box.ontop   = ontop
	notification.box.opacity = opacity
	notification.box.visible = true

	if centered_iconbox then
		--layout:add(centered_iconbox)
		layout_top:add(centered_iconbox)
	end

	layout_top:add(notification[TEXTBOX_NAME .. "app_name"])
	layout_middle:add(notification[TEXTBOX_NAME .. "title"])
	layout_middle:add(notification[TEXTBOX_NAME .. "message"])

	local completelayout = wibox.layout.fixed.vertical()
	completelayout:add(layout_top)
	completelayout:add(layout_middle)
	completelayout:add(layout_actions)
	notification.box:set_widget(completelayout)

	-- Setup the mouse events
	completelayout:buttons(gtable.join(
			button({}, event.mouse.button_click_left, nil, run),
			button({}, event.mouse.button_click_right, nil, function()
				die(naughty.notification_closed_reason.dismissed_by_user)
			end)))

	-- insert the notification to the table
	table.insert(current_notifications[s][notification.position], notification)

	if naughty.suspended and not args.ignore_suspend then
		notification.box.visible = false
	end
end

naughty.connect_signal("request::fallback", naughty.default_notification_handler)
