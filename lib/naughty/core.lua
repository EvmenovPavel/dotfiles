----------------------------------------------------------------------------
--- Notification library
--
-- @author koniu &lt;gkusnierz@gmail.com&gt;
-- @copyright 2008 koniu
-- @module naughty
----------------------------------------------------------------------------

--luacheck: no max line length

-- Package environment
local capi      = { screen  = screen,
					awesome = awesome }
local utils     = require("lib.naughty.utils")
local timer     = require("gears.timer")
local button    = require("awful.button")
local screen    = require("awful.screen")
local gtable    = require("gears.table")
local beautiful = require("beautiful")
local wibox     = require("wibox")

local function get_screen(s)
	return s and capi.screen[s]
end

local naughty = {}

--[[--
Naughty configuration - a table containing common popup settings.

@table naughty.config
@tfield[opt=apply_dpi(4)] int padding Space between popups and edge of the
  workarea.
@tfield[opt=apply_dpi(1)] int spacing Spacing between popups.
@tfield[opt={"/usr/share/pixmaps/"}] table icon_dirs List of directories
  that will be checked by `getIcon()`.
@tfield[opt={ "png", "gif" }] table icon_formats List of formats that will be
  checked by `getIcon()`.
@tfield[opt] function notify_callback Callback used to modify or reject
notifications, e.g.
    naughty.config.notify_callback = function(args)
        args.text = 'prefix: ' .. args.text
        return args
    end
  To reject a notification return `nil` from the callback.
  If the notification is a freedesktop notification received via DBUS, you can
  access the freedesktop hints via `args.freedesktop_hints` if any where
  specified.

@tfield table presets Notification presets.  See `config.presets`.

@tfield table defaults Default values for the params to `notify()`.  These can
  optionally be overridden by specifying a preset.  See `config.defaults`.

--]]

gtable.crush(naughty, require("lib.naughty.constants"))

--- Notifications font.
-- @beautiful beautiful.notification_font
-- @tparam string|lgi.Pango.FontDescription notification_font

--- Notifications background color.
-- @beautiful beautiful.notification_bg
-- @tparam color notification_bg

--- Notifications foreground color.
-- @beautiful beautiful.notification_fg
-- @tparam color notification_fg

--- Notifications border width.
-- @beautiful beautiful.notification_border_width
-- @tparam int notification_border_width

--- Notifications border color.
-- @beautiful beautiful.notification_border_color
-- @tparam color notification_border_color

--- Notifications shape.
-- @beautiful beautiful.notification_shape
-- @tparam[opt] gears.shape notification_shape
-- @see gears.shape

--- Notifications opacity.
-- @beautiful beautiful.notification_opacity
-- @tparam[opt] int notification_opacity

--- Notifications margin.
-- @beautiful beautiful.notification_margin
-- @tparam int notification_margin

--- Notifications width.
-- @beautiful beautiful.notification_width
-- @tparam int notification_width

--- Notifications height.
-- @beautiful beautiful.notification_height
-- @tparam int notification_height

--- Notifications maximum width.
-- @beautiful beautiful.notification_max_width
-- @tparam int notification_max_width

--- Notifications maximum height.
-- @beautiful beautiful.notification_max_height
-- @tparam int notification_max_height

--- Notifications icon size.
-- @beautiful beautiful.notification_icon_size
-- @tparam int notification_icon_size


-- Counter for the notifications
-- Required for later access via DBUS
local counter         = 1

-- True if notifying is suspended
local suspended       = false

--- Index of notifications per screen and position.
-- See config table for valid 'position' values.
-- Each element is a table consisting of:
--
-- @field box Wibox object containing the popup
-- @field height Popup height
-- @field width Popup width
-- @field die Function to be executed on timeout
-- @field id Unique notification id based on a counter
-- @table notifications
naughty.notifications = { suspended = { } }

local function init_screen(s)
	naughty.notifications[s] = {
		top_left      = {},
		top_middle    = {},
		top_right     = {},
		bottom_left   = {},
		bottom_middle = {},
		bottom_right  = {},
	}
end

local function removed(scr)
	-- Destroy all notifications on this screen
	naughty.destroy_all_notifications({ scr })
	naughty.notifications[scr] = nil
end

--- Notification state
function naughty.is_suspended()
	return suspended
end

--- Suspend notifications
function naughty.suspend()
	suspended = true
end

--- Resume notifications
function naughty.resume()
	suspended = false

	for _, v in pairs(naughty.notifications.suspended) do
		v.box.visible = true

		if v.timer then
			v.timer:start()
		end
	end

	naughty.notifications.suspended = { }
end

--- Toggle notification state
function naughty.toggle()
	if suspended then
		naughty.resume()
	else
		naughty.suspend()
	end
end

--- Evaluate desired position of the notification by index - internal
--
-- @param s Screen to use
-- @param position top_right | top_left | bottom_right | bottom_left
--   | top_middle | bottom_middle
-- @param idx Index of the notification
-- @param[opt] width Popup width.
-- @param height Popup height
-- @return Absolute position and index in { x = X, y = Y, idx = I } table
local function get_offset(s, position, idx, width, height)
	s        = get_screen(s)

	local ws = s.workarea
	local v  = {}

	idx      = idx or #naughty.notifications[s][position] + 1
	width    = width or naughty.notifications[s][position][idx].width

	-- calculate x
	if position:match("left") then
		v.x = ws.x + naughty.config.padding
	elseif position:match("middle") then
		v.x = ws.x + (ws.width / 2) - (width / 2)
	else
		v.x = ws.x + ws.width - (width + naughty.config.padding)
	end

	-- calculate existing popups' height
	local existing = 0
	for i = 1, idx - 1, 1 do
		existing = existing + naughty.notifications[s][position][i].height + naughty.config.spacing
	end

	-- calculate y
	if position:match("top") then
		v.y = ws.y + naughty.config.padding + existing
	else
		v.y = ws.y + ws.height - (naughty.config.padding + height + existing)
	end

	-- Find old notification to replace in case there is not enough room.
	-- This tries to skip permanent notifications (without a timeout),
	-- e.g. critical ones.
	local find_old_to_replace = function()
		for i = 1, idx - 1 do
			local n = naughty.notifications[s][position][i]
			if n.timeout > 0 then
				return n
			end
		end
		-- Fallback to first one.
		return naughty.notifications[s][position][1]
	end

	-- if positioned outside workarea, destroy oldest popup and recalculate
	if v.y + height > ws.y + ws.height or v.y < ws.y then
		naughty.destroy(find_old_to_replace())
		idx = idx - 1
		v   = get_offset(s, position, idx, width, height)
	end

	if not v.idx then
		v.idx = idx
	end

	return v
end

--- Re-arrange notifications according to their position and index - internal
--
-- @return None
local function arrange(s)
	for p in pairs(naughty.notifications[s]) do
		for i, notification in pairs(naughty.notifications[s][p]) do
			local offset = get_offset(s, p, i, notification.width, notification.height)
			notification.box:geometry({ x = offset.x, y = offset.y })
			notification.idx = offset.idx
		end
	end
end

--- Destroy notification by notification object
--
-- @param notification Notification object to be destroyed
-- @param reason One of the reasons from notificationClosedReason
-- @param[opt=false] keep_visible If true, keep the notification visible
-- @return True if the popup was successfully destroyed, nil otherwise
function naughty.destroy(notification, reason, keep_visible)
	if notification and notification.box.visible then
		if suspended then
			for k, v in pairs(naughty.notifications.suspended) do
				if v.box == notification.box then
					table.remove(naughty.notifications.suspended, k)
					break
				end
			end
		end

		local scr = notification.screen
		table.remove(naughty.notifications[scr][notification.position], notification.idx)

		if notification.timer then
			notification.timer:stop()
		end

		if not keep_visible then
			notification.box.visible = false
			arrange(scr)
		end

		if notification.destroy_cb and reason ~= naughty.notificationClosedReason.silent then
			notification.destroy_cb(reason or naughty.notificationClosedReason.undefined)
		end

		return true
	end
end

--- Destroy all notifications on given screens.
--
-- @tparam table screens Table of screens on which notifications should be
-- destroyed. If nil, destroy notifications on all screens.
-- @tparam naughty.notificationClosedReason reason Reason for closing
-- notifications.
-- @treturn true|nil True if all notifications were successfully destroyed, nil
-- otherwise.
function naughty.destroy_all_notifications(screens, reason)
	if not screens then
		screens = {}
		for key, _ in pairs(naughty.notifications) do
			table.insert(screens, key)
		end
	end

	local ret = true

	for _, scr in pairs(screens) do
		for _, list in pairs(naughty.notifications[scr]) do
			while #list > 0 do
				ret = ret and naughty.destroy(list[1], reason)
			end
		end
	end

	return ret
end

--- Get notification by ID
--
-- @param id ID of the notification
-- @return notification object if it was found, nil otherwise
function naughty.get_by_id(id)
	-- iterate the notifications to get the notfications with the correct ID
	for s in pairs(naughty.notifications) do
		for p in pairs(naughty.notifications[s]) do
			for _, notification in pairs(naughty.notifications[s][p]) do
				if notification.id == id then
					return notification
				end
			end
		end
	end
end

--- Increase notification ID by one
function naughty.get_next_notification_id()
	counter = counter + 1
	return counter
end

--- Install expiration timer for notification object.
-- @tparam notification notification Notification object.
-- @tparam number timeout Time in seconds to be set as expiration timeout.
local function set_timeout(self, timeout)
	local die = function(reason)
		naughty.destroy(self, reason)
	end

	if timeout > 0 then
		local timer_die = timer { timeout = timeout }
		timer_die:connect_signal("timeout", function() die(naughty.notificationClosedReason.expired) end)

		if not suspended then
			timer_die:start()
		end

		self.timer = timer_die
	end

	self.die = die
end

-- create textbox
local function create_textbox(text, font)
	local textbox = wmapi.widget:textbox()
	textbox:set_valign("middle")
	textbox:set_font(font)
	textbox:set_text(text)

	return textbox
end

--- Set new notification timeout.
-- @tparam notification notification Notification object, which timer is to be reset.
-- @tparam number new_timeout Time in seconds after which notification disappears.
-- @return None.
function naughty.reset_timeout(self, new_timeout)
	if self.timer then self.timer:stop() end

	local timeout = new_timeout or self.timeout
	set_timeout(self, timeout)
	self.timeout = timeout

	self.timer:start()
end

local function update_size(self)
	local size_info = self.size_info
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
	local workarea     = self.screen.workarea
	local border_width = size_info.border_width or 0
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
	self.idx = offset.idx

	-- update positions of other notifications
	arrange(self.screen)
end

--- Create a notification.
--
-- @tab args The argument table containing any of the arguments below.
-- @string[opt=""] args.text Text of the notification.
-- @string[opt] args.title Title of the notification.
-- @int[opt=5] args.timeout Time in seconds after which popup expires.
--   Set 0 for no timeout.
-- @int[opt] args.hover_timeout Delay in seconds after which hovered popup disappears.
-- @tparam[opt=focused] integer|screen args.screen Target screen for the notification.
-- @string[opt="top_right"] args.position Corner of the workarea displaying the popups.
--   Values: `"top_right"`, `"top_left"`, `"bottom_left"`,
--   `"bottom_right"`, `"top_middle"`, `"bottom_middle"`.
-- @bool[opt=true] args.ontop Boolean forcing popups to display on top.
-- @int[opt=`beautiful.notification_height` or auto] args.height Popup height.
-- @int[opt=`beautiful.notification_width` or auto] args.width Popup width.
-- @int[opt=`beautiful.notification_max_height` or auto] args.max_height Popup maximum height.
-- @int[opt=`beautiful.notification_max_width` or auto] args.max_width Popup maximum width.
-- @string[opt=`beautiful.notification_font` or `beautiful.font` or `awesome.font`] args.font Notification font.
-- @string[opt] args.icon Path to icon.
-- @int[opt] args.icon_size Desired icon size in px.
-- @string[opt=`beautiful.notification_fg` or `beautiful.fg_focus` or `'#ffffff'`] args.fg Foreground color.
-- @string[opt=`beautiful.notification_fg` or `beautiful.bg_focus` or `'#535d6c'`] args.bg Background color.
-- @int[opt=`beautiful.notification_border_width` or 1] args.border_width Border width.
-- @string[opt=`beautiful.notification_border_color` or `beautiful.border_focus` or `'#535d6c'`] args.border_color Border color.
-- @tparam[opt=`beautiful.notification_shape`] gears.shape args.shape Widget shape.
-- @tparam[opt=`beautiful.notification_opacity`] gears.opacity args.opacity Widget opacity.
-- @tparam[opt=`beautiful.notification_margin`] gears.margin args.margin Widget margin.
-- @tparam[opt] func args.run Function to run on left click.  The notification
--   object will be passed to it as an argument.
--   You need to call e.g.
--   `notification.die(naughty.notificationClosedReason.dismissedByUser)` from
--   there to dismiss the notification yourself.
-- @tparam[opt] func args.destroy Function to run when notification is destroyed.
-- @tparam[opt] table args.preset Table with any of the above parameters.
--   Note: Any parameters specified directly in args will override ones defined
--   in the preset.
-- @tparam[opt] int args.replaces_id Replace the notification with the given ID.
-- @tparam[opt] func args.callback Function that will be called with all arguments.
--   The notification will only be displayed if the function returns true.
--   Note: this function is only relevant to notifications sent via dbus.
-- @tparam[opt] table args.actions Mapping that maps a string to a callback when this
--   action is selected.
-- @bool[opt=false] args.ignore_suspend If set to true this notification
--   will be shown even if notifications are suspended via `naughty.suspend`.
-- @usage naughty.notify({ title = "Achtung!", text = "You're idling", timeout = 0 })
-- @treturn ?table The notification object, or nil in case a notification was
--   not displayed.
function naughty.notify(args)
	if naughty.config.notify_callback then
		args = naughty.config.notify_callback(args)
		if not args then
			return
		end
	end

	-- gather variables together
	local preset    = gtable.join(naughty.config.defaults or {}, args.preset or naughty.config.presets.normal or {})
	local timeout   = args.timeout or preset.timeout

	local icon_data = args.icon_data or preset.icon_data
	local icon_size = args.icon_size or preset.icon_size or beautiful.notification_icon_size

	local appname   = args.appname or preset.appname
	local message   = args.message or preset.message
	local title     = args.title or preset.title

	local s         = get_screen(args.screen or preset.screen or screen.focused())
	if not s then
		local err = "naughty.notify: there is no screen available to display the following notification:"
		err       = string.format("%s title='%s' text='%s'", err, tostring(title or ""), tostring(message or ""))
		require("gears.debug").print_warning(err)
		return
	end

	local ontop         = args.ontop or preset.ontop
	local hover_timeout = args.hover_timeout or preset.hover_timeout
	local position      = args.position or preset.position
	local actions       = args.actions
	local destroy_cb    = args.destroy

	-- beautiful
	local font          = args.font or preset.font or beautiful.notification_font or beautiful.font or capi.awesome.font
	local fg            = args.fg or preset.fg or beautiful.notification_fg or beautiful.fg_normal or '#ffffff'
	local bg            = args.bg or preset.bg or beautiful.notification_bg or beautiful.bg_normal or '#535d6c'
	local border_color  = args.border_color or preset.border_color or beautiful.notification_border_color or beautiful.bg_focus or '#535d6c'
	local border_width  = args.border_width or preset.border_width or beautiful.notification_border_width
	local shape         = args.shape or preset.shape or beautiful.notification_shape
	local width         = args.width or preset.width or beautiful.notification_width
	local height        = args.height or preset.height or beautiful.notification_height
	local max_width     = args.max_width or preset.max_width or beautiful.notification_max_width
	local max_height    = args.max_height or preset.max_height or beautiful.notification_max_height
	local margin        = args.margin or preset.margin or beautiful.notification_margin
	local opacity       = args.opacity or preset.opacity or beautiful.notification_opacity
	local notification  = { screen = s, destroy_cb = destroy_cb, timeout = timeout }

	-- replace notification if needed
	local reuse_box
	if args.replaces_id then
		local obj = naughty.get_by_id(args.replaces_id)
		if obj then
			-- destroy this and ...
			naughty.destroy(obj, naughty.notificationClosedReason.silent, true)
			reuse_box = obj.box
		end

		-- ... may use its ID
		if args.replaces_id <= counter then
			notification.id = args.replaces_id
		else
			notification.id = naughty.get_next_notification_id()
		end
	else
		-- get a brand new ID
		notification.id = naughty.get_next_notification_id()
	end

	notification.position = position

	if title then title = title .. "\n" else title = "" end

	-- hook destroy
	set_timeout(notification, timeout)
	local die                  = notification.die

	local run                  = function()
		if args.run then
			args.run(notification)
		else
			die(naughty.notificationClosedReason.dismissedByUser)
		end
	end

	local hover_destroy        = function()
		if hover_timeout == 0 then
			die(naughty.notificationClosedReason.expired)
		else
			if notification.timer then notification.timer:stop() end
			notification.timer = timer { timeout = hover_timeout }
			notification.timer:connect_signal("timeout", function() die(naughty.notificationClosedReason.expired) end)
			notification.timer:start()
		end
	end

	-- create textbox
	local wappname             = create_textbox(appname, font)
	local wtitle               = create_textbox(title, font)
	local wmessage             = create_textbox(message, font)

	local layout_actions       = nil
	local actions_max_width    = 0
	local actions_total_height = 0

	if actions then
		layout_actions, actions_total_height, actions_max_width = utils:create_actions(actions, margin, font, s)
		notification.actionsbox                                 = layout_actions
	end

	---- create iconbox
	local iconbox = nil
	if icon_data then
		iconbox              = utils:create_iconbox(icon_data, icon_size)
		notification.iconbox = iconbox
	end

	-- create container wibox
	if not reuse_box then
		notification.box = wibox({ type = "notification" })
	else
		notification.box = reuse_box
	end

	notification.box.fg                 = fg
	notification.box.bg                 = bg
	notification.box.border_color       = border_color
	notification.box.border_width       = border_width
	notification.box.shape_border_color = shape and border_color
	notification.box.shape_border_width = shape and border_width
	notification.box.shape              = shape

	if hover_timeout then notification.box:connect_signal("mouse::enter", hover_destroy) end

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

	notification.size_info = size_info

	-- position the wibox
	update_size(notification)
	notification.box.ontop    = ontop
	notification.box.opacity  = opacity
	notification.box.visible  = true

	-- App name
	local layout_top          = wibox.layout.fixed.horizontal()
	-- Icon
	local layout_middle_left  = wibox.layout.fixed.horizontal()
	-- Title + Message
	local layout_middle_right = wibox.layout.fixed.vertical()
	-- left + right meddle
	local layout_middle       = wibox.layout.fixed.horizontal()

	-- populate widgets
	if iconbox then
		layout_middle_left:add(iconbox)
	end

	layout_top:add(wappname)
	layout_middle_right:add(wtitle)
	layout_middle_right:add(wmessage)

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
	table.insert(naughty.notifications[s][notification.position], notification)

	if suspended and not args.ignore_suspend then
		notification.box.visible = false
		table.insert(naughty.notifications.suspended, notification)
	end

	-- return the notification
	return notification
end

screen.connect_for_each_screen(init_screen)

capi.screen.connect_signal("removed", removed)

return naughty

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
