---------------------------------------------------------------------------
-- DBUS/Notification support
-- Notify
--
-- @author koniu &lt;gkusnierz@gmail.com&gt;
-- @copyright 2008 koniu
-- @module naughty.dbus
---------------------------------------------------------------------------

-- Package environment
local pairs           = pairs
local string          = string
local capi            = { awesome = awesome,
                          dbus    = dbus,
                          type    = type }
local gsurface        = require("gears.surface")
local gdebug          = require("gears.debug")
local protected_call  = require("gears.protected_call")

local lgi             = require("lgi")
local cairo           = lgi.cairo
local Gio             = lgi.Gio
local GLib            = lgi.GLib
local GObject         = lgi.GObject

local schar           = string.char
local sbyte           = string.byte
local tcat            = table.concat
local tins            = table.insert
local unpack          = unpack or table.unpack -- luacheck: globals unpack (compatibility with Lua 5.1)
local naughty         = require("lib.naughty.core")
local cst             = require("lib.naughty.constants")
local nnotif          = require("lib.naughty.notification")
local naction         = require("lib.naughty.action")

local capabilities    = {
    "body", "body-markup", "icon-static", "actions", "action-icons"
}

local dbus_connection = {
    session = "session",
    system  = "system",
}

local dbus_method     = {
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

--- Notification library, dbus bindings
local dbus            = { config = {} }

local bus_connection  = nil

-- DBUS Notification constants
-- https://specifications.freedesktop.org/notification-spec/notification-spec-latest.html#urgency-levels
local urgency         = {
    low      = "\0",
    normal   = "\1",
    critical = "\2"
}

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
    log:info("sendActionInvoked", notificationId, action)

    if capi.dbus then
        capi.dbus:emit_signal(dbus_connection.session, "/org/freedesktop/Notifications",
                              dbus_method.dbusNotificationsInterface, "ActionInvoked",
                              GLib.Variant("(us)", { notificationId, action }))
    end
end

local function sendNotificationClosed(notificationId, reason)
    log:info("sendNotificationClosed", notificationId, reason)

    if reason <= 0 then
        reason = cst.notification_closed_reason.undefined
    end
    if capi.dbus then
        capi.dbus:emit_signal(dbus_connection.session, "/org/freedesktop/Notifications",
                              dbus_method.dbusNotificationsInterface, "NotificationClosed",
                              GLib.Variant("(uu)", { notificationId, reason }))
    end
end

function is_empty(s)
    return s == nil or s == ""
end

local function convert_icon(w, h, rowstride, channels, data)
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

function notif_methods.GetCapabilities(data)
    log:debug("\nnotif_methods.GetCapabilities")
    -- We actually do display the body of the message, we support <b>, <i>
    -- and <u> in the body and we handle static (non-animated) icons.

    return GLib.Variant("(as)", { capabilities })
end

function notif_methods.CloseNotification(id)
    log:debug("\nnotif_methods.CloseNotification")
    --local obj = naughty.get_by_id(parameters.value[1])
    --if obj then
    --    obj:destroy(cst.notification_closed_reason.dismissed_by_command)
    --end

    return GLib.Variant("()")
end

function notif_methods.Notify(data, appname, replaces_id, app_icon, title, text, actions, hints, expire)
    if data == nil then
        return
    end

    local type, method, sender, bus, object_path, interface = unpack(data)

    local args                                              = {}
    if text ~= "" then
        args.message = text
        if title ~= "" then
            args.title = title
        end
    else
        if title ~= "" then
            args.message = title
        else
            -- FIXME: We have to reply *something* to the DBus invocation.
            -- Right now this leads to a memory leak, I think.
            return
        end
    end

    if appname ~= "" then
        args.appname  = appname --TODO v6 Remove this.
        args.app_name = appname
    end

    local preset = args.preset or cst.config.defaults
    local notification
    if actions then
        args.actions = {}

        for i = 1, #actions, 2 do
            local action_id   = actions[i]
            local action_text = actions[i + 1]

            if action_id == "default" then
                args.run = function()
                    sendActionInvoked(notification.id, "default")
                    notification:destroy(cst.notification_closed_reason.dismissed_by_user)
                end
            elseif action_id ~= nil and action_text ~= nil then

                local a = naction {
                    name     = action_text,
                    id       = action_id,
                    position = (i - 1) / 2 + 1,
                }

                -- Right now `gears` doesn't have a great icon implementation
                -- and `naughty` doesn't depend on `menubar`, so delegate the
                -- icon "somewhere" using a request.
                if hints["action-icons"] and action_id ~= "" then
                    naughty.emit_signal("request::action_icon", a, "dbus", { id = action_id })
                end

                a:connect_signal("invoked", function()
                    sendActionInvoked(notification.id, action_id)

                    if not notification.resident then
                        notification:destroy(cst.notification_closed_reason.dismissed_by_user)
                    end
                end)

                table.insert(args.actions, a)
            end
        end
    end

    args.destroy      = function(reason)
        sendNotificationClosed(notification.id, reason)
    end

    local legacy_data = { -- This data used to be generated by AwesomeWM's C code
        type   = type --[[ "method_call" ]], interface = interface, path = object_path,
        member = method, sender = sender, bus = bus --[[ "session" ]]
    }

    if not preset.callback or (type(preset.callback) == "function" and
            preset.callback(legacy_data, appname, replaces_id, app_icon, title, text, actions, hints, expire)) then

        if app_icon ~= "" then
            args.app_icon = app_icon
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
            local w, h, rowstride, _, _, channels, icon_data = unpack(hints.icon_data)

            args.image                                       = convert_icon(w, h, rowstride, channels, icon_data)
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

        log:info("replaces_id", replaces_id)
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
            for name, key in pairs(urgency) do
                if is_empty(hints.urgency) then
                    local b = string.char(hints.urgency)
                    if key == b then
                        args.urgency = name
                    end
                end
            end
        end

        args.urgency = args.urgency or "normal"

        -- Try to update existing objects when possible
        notification = naughty.get_by_id(replaces_id)

        --local client = dbus.get_clients(notification)
        --log:debug("client", client)

        if notification then
            if not notification._private._unique_sender then
                -- If this happens, the notification is either trying to
                -- highjack content created within AwesomeWM or it is garbage
                -- to begin with.
                gdebug.print_warning(
                        "A notification has been received, but tried to update " ..
                                "the content of a notification it does not own."
                )
            elseif notification._private._unique_sender ~= sender then
                -- Nothing says you cannot and some scripts may do it
                -- accidentally, but this is rather unexpected.
                gdebug.print_warning(
                        "Notification " .. notification.title .. " is being updated" ..
                                "by a different DBus connection (" .. sender .. "), this is " ..
                                "suspicious. The original connection was " ..
                                notification._private._unique_sender
                )
            end

            for k, v in pairs(args) do
                if k == "destroy" then
                    k = "destroy_cb"
                end
                notification[k] = v
            end

            -- Update the icon if necessary.
            if app_icon ~= notification._private.app_icon then
                notification._private.app_icon = app_icon

                naughty._emit_signal_if(
                        "request::icon", function()
                            if notification._private.icon then
                                return true
                            end
                        end, notification, "dbus_clear", {}
                )
            end

            -- Even if no property changed, restart the timeout.
            notification:reset_timeout()
        else
            -- Only set the sender for new notifications.
            args._unique_sender = sender

            notification        = nnotif.create(args)

            naughty.connect_signal("destroyed", function(n, reason)
                args.destroy(reason)
            end)
        end

        return GLib.Variant("(u)", { notification.id })
    end

    return GLib.Variant("(u)", { naughty._gen_next_id() })
end

function notif_methods.GetServerInfo()
    log:info("\nnotif_methods.GetServerInfo")

    local return_name, return_vendor, return_version

    return GLib.Variant("(u)", { return_name, return_vendor, return_version })
end

function notif_methods.GetServerInformation(data)
    log:debug("\nnotif_methods.GetServerInformation")
    -- name of notification app, name of vender, version, specification version

    local type      = data["type"]
    local path      = data["path"]
    local bus       = data["bus"]
    local member    = data["member"]
    local interface = data["interface"]
    local sender    = data["sender"]

    log:info(">>", type, path, bus, member, interface, sender)

    return GLib.Variant("(ssss)", {
        "naughty", "awesome", capi.awesome.version, "1.2"
    })
end

--[[
method QString org.freedesktop.DBus.Introspectable.Introspect()
signal void org.freedesktop.Notifications.ActionInvoked(uint id, QString action_key)
signal void org.freedesktop.Notifications.NotificationClosed(uint id, uint reason)
method void org.freedesktop.Notifications.CloseNotification(uint id)
method QStringList org.freedesktop.Notifications.GetCapabilities()
method QString org.freedesktop.Notifications.GetServerInfo(QString& return_vendor, QString& return_version)
method QString org.freedesktop.Notifications.GetServerInformation(QString& return_vendor, QString& return_version, QString& return_spec_version)
method uint org.freedesktop.Notifications.Notify(QString app_name, uint id, QString icon, QString summary, QString body, QStringList actions, QVariantMap hints, int timeout)
]]

local function method_call(data, ...)
    log:info("method_call")
    if data == nil then
        return
    end

    log:info("data.member", data.member)

    --if notif_methods[data.member] then
    --    protected_call(notif_methods[data.member], data, ...)
    --end
end

local function remove_capability(cap)
    for k, v in ipairs(capabilities) do
        if v == cap then
            table.remove(capabilities, k)
            break
        end
    end
end

capi.dbus.connect_signal(dbus_method.dbusRemoveMatch, method_call)
capi.dbus.connect_signal(dbus_method.dbusAddMatch, method_call)
capi.dbus.connect_signal(dbus_method.dbusObjectPath, method_call)
capi.dbus.connect_signal(dbus_method.dbusNotificationsInterface, method_call)
capi.dbus.connect_signal(dbus_method.signalNotificationClosed, method_call)
capi.dbus.connect_signal(dbus_method.signalActionInvoked, method_call)
capi.dbus.connect_signal(dbus_method.callGetCapabilities, method_call)
capi.dbus.connect_signal(dbus_method.callCloseNotification, method_call)
capi.dbus.connect_signal(dbus_method.callNotify, method_call)
capi.dbus.connect_signal(dbus_method.callGetServerInformation, method_call)

--capi.dbus.connect_signal(dbus_method.dbusNotificationsInterface, notif_methods.Notify)

capi.dbus.connect_signal("org.freedesktop.DBus.Introspectable", function(data)
    log:info("org.freedesktop.DBus.Introspectable")

    if data.member == "Introspect" then
        local xml = [=["<!DOCTYPE node PUBLIC "-//freedesktop//DTD D-BUS Object
                    Introspection 1.0//EN"
                    "http://www.freedesktop.org/standards/dbus/1.0/introspect.dtd">
                    <node>
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
                    </node>"]=]
        return "s", xml
    end
end)

-- listen for dbus notification requests
capi.dbus.request_name(dbus_connection.session, dbus_method.dbusNotificationsInterface)

-- Update the capabilities.
naughty.connect_signal("property::persistence_enabled", function()
    remove_capability("persistence")

    if naughty.persistence_enabled then
        table.insert(capabilities, "persistence")
    end
end)
naughty.connect_signal("property::image_animations_enabled", function()
    remove_capability("icon-multi")
    remove_capability("icon-static")

    table.insert(capabilities, naughty.persistence_enabled
            and "icon-multi" or "icon-static"
    )
end)

-- For the tests.
dbus._capabilities = capabilities

return dbus

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
