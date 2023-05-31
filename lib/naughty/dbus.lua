---------------------------------------------------------------------------
-- DBUS/Notification support
-- Notify
--
-- @author koniu &lt;gkusnierz@gmail.com&gt;
-- @copyright 2008 koniu
-- @module naughty.dbus
---------------------------------------------------------------------------

assert(dbus)

-- Package environment
local capi            = { awesome = awesome,
						  dbus    = dbus }
local naughty         = require("lib.naughty.core")
local naction         = require("lib.naughty.action")
local utils           = require("lib.naughty.utils")
local cst             = require("lib.naughty.constants")
local protected_call  = require("gears.protected_call")
local unpack          = unpack or table.unpack

local dbus_connection = {
	session = "session",
	system  = "system",
}

local dbus_method     = {
	dbusIntrospectable         = "org.freedesktop.DBus.Introspectable",
	dbusRemoveMatch            = "org.freedesktop.DBus.RemoveMatch",
	dbusAddMatch               = "org.freedesktop.DBus.AddMatch",
	dbusObjectPath             = "/org/freedesktop/Notifications", -- the DBUS object path
	dbusNotificationsInterface = "org.freedesktop.Notifications", -- DBUS Interface
	signalNotificationClosed   = "org.freedesktop.Notifications.NotificationClosed",
	signalActionInvoked        = "org.freedesktop.Notifications.ActionInvoked",
	callGetCapabilities        = "org.freedesktop.Notifications.GetCapabilities",
	callCloseNotification      = "org.freedesktop.Notifications.CloseNotification",
	callNotify                 = "org.freedesktop.Notifications.Notify",
	callGetServerInformation   = "org.freedesktop.Notifications.GetServerInformation",
}

local data_method     = {
	Notify               = "Notify",
	CloseNotification    = "CloseNotification",
	GetServerInfo        = "GetServerInfo",
	GetServerInformation = "GetServerInformation",
	GetCapabilities      = "GetCapabilities",
}

--- Notification library, dbus bindings
local dbus            = { config = {} }

--- DBUS notification to preset mapping.
-- The first element is an object containing the filter.
-- If the rules in the filter match, the associated preset will be applied.
-- The rules object can contain the following keys: urgency, category, appname.
-- The second element is the preset.
-- @tfield table 1 low urgency
-- @tfield table 2 normal urgency
-- @tfield table 3 critical urgency
-- @table config.mapping
dbus.config.mapping   = cst.config.mapping

local function sendActionInvoked(notificationId, action)
	if capi.dbus then
		capi.dbus.emit_signal(dbus_connection.session, dbus_method.dbusObjectPath,
				dbus_method.dbusNotificationsInterface, "ActionInvoked",
				"u", notificationId,
				"s", action)
	end
end

local function sendNotificationClosed(notificationId, reason)
	if reason <= 0 then
		reason = cst.notification_closed_reason.undefined
	end

	if capi.dbus then
		capi.dbus.emit_signal(dbus_connection.session, dbus_method.dbusObjectPath,
				dbus_method.dbusNotificationsInterface, "NotificationClosed",
				"u", notificationId,
				"u", reason)
	end
end

local notif_methods = {}

function notif_methods.RemoveMatch()
	log:debug("\nnotif_methods.RemoveMatch")
end

function notif_methods.AddMatch()
	log:debug("\nnotif_methods.AddMatch")
end

function notif_methods.Notifications()
	log:debug("\nnotif_methods.Notifications")
end

function notif_methods.NotificationClosed()
	log:debug("\nnotif_methods.NotificationClosed")
end

function notif_methods.ActionInvoked()
	log:debug("\nnotif_methods.ActionInvoked")
end

function notif_methods.GetCapabilities()
	-- We actually do display the body of the message, we support <b>, <i>
	-- and <u> in the body and we handle static (non-animated) icons.

	return "as", { "s", "body", "s", "body-markup", "s", "icon-static", "s", "actions" }
end

function notif_methods.CloseNotification(id)
	local obj = naughty.get_by_id(id)
	if obj then
		obj:destroy(cst.notification_closed_reason.dismissed_by_command)
	end

	return "()"
end

function notif_methods.Notify(data, appname, replaces_id, app_icon, title, message, actions, hints, expire)
	local args = {}

	if appname ~= "" then
		args.appname = appname
	end

	if message ~= "" then
		args.message = message
	else
		args.message = "Error: NULL"
		log:error("notif_methods.Notify > message: = null")
	end

	if title ~= "" then
		args.title = title
	end

	local preset       = args.preset or cst.config.defaults
	local notification = { }
	if actions then
		args.actions = {}

		for i = 1, #actions, 2 do
			local action_id   = actions[i]
			local action_text = actions[i + 1]

			if action_id == "default" then
				args.run = function()
					sendActionInvoked(notification.id, "default")
					naughty.destroy(notification, cst.notification_closed_reason.dismissed_by_user)
				end
			elseif action_id ~= nil and action_text ~= nil then

				local action = naction {
					name     = action_text,
					id       = action_id,
					position = (i - 1) / 2 + 1,
				}

				-- Right now `gears` doesn't have a great icon implementation
				-- and `naughty` doesn't depend on `menubar`, so delegate the
				-- icon "somewhere" using a request.
				if hints["action-icons"] and action_id ~= "" then
					naughty.emit_signal("request::action_icon", action, "dbus", { id = action_id })
				end

				action:connect_signal("invoked", function()
					sendActionInvoked(notification.id, action_id)

					if not notification.resident then
						naughty.destroy(notification, cst.notification_closed_reason.dismissed_by_user)
					end
				end)

				table.insert(args.actions, action)
			end
		end
	end

	args.destroy      = function(reason)
		sendNotificationClosed(notification.id, reason)
	end

	local legacy_data = { -- This data used to be generated by AwesomeWM's C code
		type   = data.type --[[ "method_call" ]], interface = data.interface, path = data.path,
		member = data.member, sender = data.sender, bus = data.bus --[[ dbus_connection.session ]]
	}

	if not preset.callback or (type(preset.callback) == "function" and
			preset.callback(legacy_data, appname, replaces_id, app_icon, title, message, actions, hints, expire)) then

		if app_icon ~= "" then
			args.icon_data = app_icon
		elseif hints.icon_data or hints.image_data then
			if hints.icon_data == nil then
				hints.icon_data = hints.image_data
			end

			-- icon_data is an array:
			-- 1 -> width
			-- 2 -> height
			-- 3 -> rowstride
			-- 4 -> has alpha
			-- 5 -> bits per sample
			-- 6 -> channels
			-- 7 -> data

			-- Get the value as a GVariant and then use LGI's special
			-- GVariant.data to get that as an LGI byte buffer. That one can
			-- then by converted to a string via its __tostring metamethod.

			local width, height, rowstride, has, bits, channels, icon_data = unpack(hints.icon_data)

			args.icon_data                                                 = utils:convert_icon(width, height, rowstride, channels, icon_data)
		end

		-- Alternate ways to set the icon. The specs recommends to allow both
		-- the icon and image to co-exist since they serve different purpose.
		-- However in case the icon isn't specified, use the image.
		--args.image = args.image
		--        or hints["image-path"] -- not deprecated
		--        or hints["image_path"] -- deprecated

		if naughty.image_animations_enabled then
			args.images = args.images or {}
		end

		if replaces_id and replaces_id ~= "" and replaces_id ~= 0 then
			args.replaces_id = replaces_id
		end

		if expire and expire > -1 then
			args.timeout = expire / 1000
		end

		args.freedesktop_hints = hints

		-- Not very pretty, but given the current format is documented in the
		-- public API... well, whatever...
		if hints and hints.urgency then
			for name, key in pairs(cst.config._urgency) do
				if not utils:is_empty(hints.urgency) then
					local urgency = tostring(hints.urgency)
					if name == urgency or key == urgency then
						args.urgency = name
					end
				end
			end
		end

		args.urgency = args.urgency or "normal"

		notification = naughty.notify(args)

		if notification ~= nil then
			return "u", notification.id
		end
	end

	return "u", naughty.get_next_notification_id()
end

function notif_methods.GetServerInfo()
	return "s", "naughty", "s", "awesome", "s", capi.awesome.version, "s", "1.0"
end

function notif_methods.GetServerInformation()
	-- name of notification app, name of vender, version, specification version
	return notif_methods.GetServerInfo()
end

local function method_call(data, ...)
	if data_method[data.member] then
		return protected_call(notif_methods[data.member], data, ...)
	end
end

capi.dbus.connect_signal(dbus_method.dbusNotificationsInterface, method_call)

capi.dbus.connect_signal(dbus_method.dbusRemoveMatch,
		function(_1, _2, _3, _4, _5, _6, _7, _8, _9, _0)
			log:info("org.freedesktop.DBus.RemoveMatch")
		end)
capi.dbus.connect_signal(dbus_method.dbusAddMatch,
		function(_1, _2, _3, _4, _5, _6, _7, _8, _9, _0)
			log:info("org.freedesktop.DBus.AddMatch")
		end)
capi.dbus.connect_signal(dbus_method.signalNotificationClosed,
		function(_1, _2, _3, _4, _5, _6, _7, _8, _9, _0)
			log:info("org.freedesktop.Notifications.NotificationClosed")
		end)
capi.dbus.connect_signal(dbus_method.signalActionInvoked,
		function(_1, _2, _3, _4, _5, _6, _7, _8, _9, _0)
			log:info("org.freedesktop.Notifications.ActionInvoked")
		end)
capi.dbus.connect_signal(dbus_method.callGetCapabilities,
		function(_1, _2, _3, _4, _5, _6, _7, _8, _9, _0)
			log:info("org.freedesktop.Notifications.GetCapabilities")
		end)
capi.dbus.connect_signal(dbus_method.callCloseNotification,
		function(_1, _2, _3, _4, _5, _6, _7, _8, _9, _0)
			log:info("org.freedesktop.Notifications.CloseNotification")
		end)
capi.dbus.connect_signal(dbus_method.callNotify,
		function(_1, _2, _3, _4, _5, _6, _7, _8, _9, _0)
			log:info("org.freedesktop.Notifications.Notify")
		end)
capi.dbus.connect_signal(dbus_method.callGetServerInformation,
		function(_1, _2, _3, _4, _5, _6, _7, _8, _9, _0)
			log:info("org.freedesktop.Notifications.GetServerInformation")
		end)

local function dbusIntrospectable(data)
	log:info("data", data)
	if data.member == "Introspect" then
		local xml = [=[<!DOCTYPE node PUBLIC "-//freedesktop//DTD D-BUS Object
					Introspection 1.0//EN"
					"http://www.freedesktop.org/standards/dbus/1.0/introspect.dtd">
					<node>
					  <interface name="org.freedesktop.Notifications.NotificationClosed">
						<method name="NotificationClosed">
						  <arg name="data" direction="out" type="s"/>
						</method>
					  </interface>
					  <interface name="org.freedesktop.DBus.RemoveMatch">
						<method name="RemoveMatch">
						  <arg name="data" direction="out" type="s"/>
						</method>
					  </interface>
					  <interface name="org.freedesktop.DBus.AddMatch">
						<method name="AddMatch">
						  <arg name="data" direction="out" type="s"/>
						</method>
					  </interface>
					  <interface name="org.freedesktop.DBus.Introspectable">
						<method name="Introspect">
						  <arg name="data" direction="out" type="s"/>
						</method>
					  </interface>
					  <interface name="org.freedesktop.Notifications">
						<method name="GetCapabilities">
						  <arg name="caps" type="as" direction="out"/>
						</method>
						<method name="CloseNotification">
						  <arg name="id" type="u" direction="in"/>
						</method>
						<method name="Notify">
						  <arg name="app_name" type="s" direction="in"/>
						  <arg name="id" type="u" direction="in"/>
						  <arg name="icon" type="s" direction="in"/>
						  <arg name="summary" type="s" direction="in"/>
						  <arg name="body" type="s" direction="in"/>
						  <arg name="actions" type="as" direction="in"/>
						  <arg name="hints" type="a{sv}" direction="in"/>
						  <arg name="timeout" type="i" direction="in"/>
						  <arg name="return_id" type="u" direction="out"/>
						</method>
						<method name="GetServerInformation">
						  <arg name="return_name" type="s" direction="out"/>
						  <arg name="return_vendor" type="s" direction="out"/>
						  <arg name="return_version" type="s" direction="out"/>
						  <arg name="return_spec_version" type="s" direction="out"/>
						</method>
						<method name="GetServerInfo">
						  <arg name="return_name" type="s" direction="out"/>
						  <arg name="return_vendor" type="s" direction="out"/>
						  <arg name="return_version" type="s" direction="out"/>
					   </method>
					   <signal name="NotificationClosed">
						  <arg name="id" type="u" direction="out"/>
						  <arg name="reason" type="u" direction="out"/>
					   </signal>
					   <signal name="ActionInvoked">
						  <arg name="id" type="u" direction="out"/>
						  <arg name="action_key" type="s" direction="out"/>
					   </signal>
					  </interface>
					</node>]=]
		return "s", xml
	end
end

capi.dbus.connect_signal(dbus_method.dbusIntrospectable, dbusIntrospectable)

-- listen for dbus notification requests
dbus.notification = function(type, appname, title, text, app_icon, urgency)
	notif_methods.Notify({  }, appname, 0, app_icon, title, text,
			{
				"> 1", function() log:info("actions 'click >1'")
			end,
				"> 2", function() log:info("actions 'click >2'")
			end
			},
			{ urgency = urgency or "normal" }, -1)
end

return dbus

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
