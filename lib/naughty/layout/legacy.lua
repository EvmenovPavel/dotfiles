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

local capi                  = {
	screen  = screen,
	awesome = awesome }
local naughty               = require("lib.naughty.core")
local utils                 = require("lib.naughty.layout.utils")
local screen                = require("awful.screen")
local button                = require("awful.button")
local beautiful             = require("beautiful")
local wibox                 = require("wibox")
local gtable                = require("gears.table")
local timer                 = require("gears.timer")
local gears                 = require("gears")

local prop_key              = "textbox_"

local properties            = {
	app_name = "app_name",
	title    = "title",
	message  = "message"
}

-- This is a copy of the table found in `naughty.core`. The reason the copy
-- exists is to make sure there is only unidirectional coupling between the
-- legacy widget (this class) and `naughty.core`. Exposing the "raw"
-- notification list is also a bad design and might cause indices and position
-- corruption. While it cannot be removed from the public API (yet), it can at
-- least be blacklisted internally.
local current_notifications = setmetatable({}, { __mode = "k" })

local function get_screen(s)
	return s and capi.screen[s]
end

local function init_screen(s)
	current_notifications[s] = {
		top_left      = {},
		top_middle    = {},
		top_right     = {},
		bottom_left   = {},
		bottom_middle = {},
		bottom_right  = {},
		middle        = {},
	}
end

local function removed(s)
	timer.delayed_call(function()
		current_notifications[s] = nil
	end)
end

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
		idx = idx - 1
		v   = get_offset(s, position, idx, width, height)
	end

	if not v.idx then
		v.idx = idx
	end

	return v
end

local function update_size(self)
	local n_self    = self
	local size_info = n_self.size_info
	local width     = 350
	local height    = 95

	if width < size_info.actions_max_width then
		width = size_info.actions_max_width
	end

	if size_info.max_width then
		width = math.min(width, size_info.max_width)
	end

	height = height + size_info.actions_total_height

	if size_info.max_height then
		height = math.min(height, size_info.max_height)
	end

	-- crop to workarea size if too big
	local workarea     = n_self.screen.workarea
	local border_width = size_info.border_width or 0
	local padding      = naughty.config.padding or 0

	if width > workarea.width - 2 * border_width - 2 * padding then
		width = workarea.width - 2 * border_width - 2 * padding
	end

	if height > workarea.height - 2 * border_width - 2 * padding then
		height = workarea.height - 2 * border_width - 2 * padding
	end

	-- set size in notification object
	n_self.height = height + 2 * border_width
	n_self.width  = width + 2 * border_width

	local offset  = get_offset(n_self.screen, n_self.position, n_self.idx, n_self.width, n_self.height)
	n_self.box:geometry({
		width  = width,
		height = height,
		x      = offset.x,
		y      = offset.y,
	})
	n_self.idx = offset.idx

	-- update positions of other notifications
	naughty.arrange(n_self.screen)
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

local function destroyed(self, _ --[[reason]], keep_visible)
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

	naughty.arrange(scr)
end

-- Don't copy paste the list of fallback, it is hard to spot mistakes.
local function get_value(notification, args, preset, prop)
	return notification[prop] -- set by the rules
			or args[prop] -- magic and undocumented, but used by the legacy API
			or preset[prop] --deprecated
			or beautiful["notification_" .. prop] -- from the theme
end

-- create textbox
local function create_textbox(self, prop, font)
	local textbox = wmapi.widget:textbox()
	textbox:set_valign("middle")
	textbox:set_font(font)
	textbox:set_text(self[prop])

	self[prop_key .. prop] = textbox
end

--- Re-arrange notifications according to their position and index - internal
--
-- @return None
function naughty.arrange(s)
	-- {} in case the screen has been deleted
	for p in pairs(current_notifications[s] or {}) do
		for i, notification in pairs(current_notifications[s][p]) do
			local offset = get_offset(s, p, i, notification.width, notification.height)
			notification.box:geometry({ x = offset.x, y = offset.y })
		end
	end
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

	local screen   = get_screen(
			get_value(notification, args, preset, "screen") or screen.focused()
	)

	if not screen then
		local err = "lib.naughty.notify: there is no screen available to display the following notification:"
		err       = string.format("%s app_name='%s' title='%s' text='%s'", err, tostring(app_name or ""), tostring(title or ""), tostring(message or ""))
		require("gears.debug").print_warning(err)
		return
	end

	local timeout           = get_value(notification, args, preset, "timeout")
	local icon_data         = get_value(notification, args, preset, "icon")
	local icon_size         = get_value(notification, args, preset, "icon_size")
	local ontop             = get_value(notification, args, preset, "ontop")
	local hover_timeout     = get_value(notification, args, preset, "hover_timeout")
	local position          = get_value(notification, args, preset, "position")
	local opacity           = get_value(notification, args, preset, "opacity")

	local actions           = notification.actions or args.actions
	local destroy_cb        = args.destroy

	local icon              = args.icon or preset.icon
	local shape             = get_value(notification, args, preset, "shape")

	-- beautiful
	local font              = get_value(notification, args, preset, "font") or beautiful.font or capi.awesome.font
	local fg                = get_value(notification, args, preset, "fg") or beautiful.fg_normal or '#ffffff'
	local bg                = get_value(notification, args, preset, "bg") or beautiful.bg_normal or '#535d6c'
	local border_color      = get_value(notification, args, preset, "border_color") or beautiful.bg_focus or '#535d6c'

	local size_info         = {
		width                = get_value(notification, args, preset, "width"),
		height               = get_value(notification, args, preset, "height"),
		max_width            = get_value(notification, args, preset, "max_width"),
		max_height           = get_value(notification, args, preset, "max_height"),
		margin               = get_value(notification, args, preset, "margin"),
		border_width         = get_value(notification, args, preset, "border_width"),
		border_height        = get_value(notification, args, preset, "border_height"),
		actions_max_width    = 0,
		actions_total_height = 0,
	}

	notification.screen     = screen
	notification.destroy_cb = destroy_cb
	notification.timeout    = timeout
	notification.position   = position

	-- hook destroy
	--set_timeout(notification, timeout)
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

	for _, prop in pairs(properties) do
		create_textbox(notification, prop, font)
	end

	local function update_textbox(self, _1, _2)
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

	-- App name
	local layout_top          = wibox.layout.fixed.horizontal()
	-- Icon
	local layout_middle_left  = wibox.layout.fixed.horizontal()
	-- Title + Message
	local layout_middle_right = wibox.layout.fixed.vertical()
	-- left + right meddle
	local layout_middle       = wibox.layout.fixed.horizontal()

	local layout_actions      = nil
	if actions then
		layout_actions, size_info.actions_total_height, size_info.actions_max_width = utils:create_actions(notification, actions, size_info.margin, font, screen)
	end

	-- create iconbox
	local iconbox = nil
	if icon_data then
		iconbox              = utils:create_iconbox(notification, icon_data, icon_size, icon, size_info)
		notification.iconbox = iconbox
	end

	-- create container wibox
	if not notification.reuse_box then
		notification.box = wibox({ fg                 = fg,
								   bg                 = bg,
								   border_color       = border_color,
								   border_width       = size_info.border_width,
								   shape_border_color = shape and border_color,
								   shape_border_width = shape and size_info.border_width,
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

	if iconbox then
		layout_middle_left:add(iconbox)
	end

	layout_top:add(notification[prop_key .. properties.app_name])
	layout_middle_right:add(notification[prop_key .. properties.title])
	layout_middle_right:add(notification[prop_key .. properties.message])

	layout_middle:add(layout_middle_left)
	layout_middle:add(layout_middle_right)

	local completelayout = wibox.layout.fixed.vertical()
	completelayout:add(layout_top)
	completelayout:add(layout_middle)

	if layout_actions then
		completelayout:add(layout_actions)
	end

	local marginbox = wibox.container.margin()
	marginbox:set_margins(10)
	marginbox:set_widget(completelayout)

	notification.box:set_widget(marginbox)

	-- Setup the mouse events
	marginbox:buttons(gtable.join(
			button({}, event.mouse.button_click_left, nil, run),
			button({}, event.mouse.button_click_right, nil, function()
				die(naughty.notification_closed_reason.dismissed_by_user)
			end)))

	-- insert the notification to the table
	table.insert(current_notifications[screen][notification.position], notification)

	if naughty.suspended and not args.ignore_suspend then
		notification.box.visible = false
	end

	return notification
end

screen.connect_for_each_screen(init_screen)

capi.screen.connect_signal("removed", removed)

naughty.connect_signal("destroyed", destroyed)
naughty.connect_signal("request::fallback", naughty.default_notification_handler)
