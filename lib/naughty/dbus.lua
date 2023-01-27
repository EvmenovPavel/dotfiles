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
local type            = type
local string          = string
local capi            = { awesome = awesome,
                          dbus    = dbus, }
local gsurface        = require("gears.surface")
local gdebug          = require("gears.debug")
local protected_call  = require("gears.protected_call")

local lgi             = require("lgi")
local cairo           = lgi.cairo

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
    log:info("sendActionInvoked", notificationId, action)

    if capi.dbus then
        capi.dbus.emit_signal(dbus_connection.session, dbus_method.dbusObjectPath,
                              dbus_method.dbusNotificationsInterface, "ActionInvoked",
                              "u", notificationId,
                              "s", action)
    end
end

local function sendNotificationClosed(notificationId, reason)
    log:info("sendNotificationClosed", notificationId, reason)

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

function notif_methods.GetCapabilities()
    log:debug("\nnotif_methods.GetCapabilities")
    -- We actually do display the body of the message, we support <b>, <i>
    -- and <u> in the body and we handle static (non-animated) icons.

    return "as", { "s", "body", "s", "body-markup", "s", "icon-static", "s", "actions" }
end

function notif_methods.CloseNotification(id)
    log:debug("\nnotif_methods.CloseNotification")

    local obj = naughty.get_by_id(id)
    if obj then
        obj:destroy(cst.notification_closed_reason.dismissed_by_command)
    end

    return "()"
end

function notif_methods.Notify(data, appname, replaces_id, app_icon, title, text, actions, hints, expire)
    log:info("\n\nnotif_methods.Notify")

    local args = {}
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
        type   = data.type --[[ "method_call" ]], interface = data.interface, path = data.path,
        member = data.member, sender = data.sender, bus = data.bus --[[ dbus_connection.session ]]
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
            local w, h, rowstride, has, bits, channels, icon_data = unpack(hints.icon_data)

            args.image                                            = convert_icon(w, h, rowstride, channels, icon_data)
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

        log:info("urgency", hints.urgency)

        -- Not very pretty, but given the current format is documented in the
        -- public API... well, whatever...
        if hints and hints.urgency then
            for name, key in pairs(cst.config._urgency) do
                if not is_empty(hints.urgency) then
                    local urgency = tostring(hints.urgency)
                    if name == urgency or key == urgency then
                        args.urgency = name
                    end
                end
            end
        end

        args.urgency = args.urgency or "normal"

        notification = nnotif(args)

        if notification ~= nil then
            return "u", notification.id
        end
    end

    return "u", naughty.get_next_notification_id()
end

function notif_methods.GetServerInfo()
    log:info("\nnotif_methods.GetServerInfo")

    return "s", "naughty", "s", "awesome", "s", capi.awesome.version, "s", "1.0"
end

function notif_methods.GetServerInformation()
    log:debug("\nnotif_methods.GetServerInformation")
    -- name of notification app, name of vender, version, specification version

    return notif_methods.GetServerInfo()
end

local function method_call(data, ...)
    if data_method[data.member] then
        return protected_call(notif_methods[data.member], data, ...)
    end
end

local function remove_capability(cap)
    for k, v in ipairs(capabilities) do
        if v == cap then
            table.remove(capabilities, k)
            break
        end
    end
end

capi.dbus.connect_signal(dbus_method.dbusNotificationsInterface, method_call)
capi.dbus.connect_signal("org.freedesktop.DBus.Introspectable", function(data)
    if data.member == "Introspect" then
        local xml = [=[<!DOCTYPE node PUBLIC "-//freedesktop//DTD D-BUS Object
    Introspection 1.0//EN"
    "http://www.freedesktop.org/standards/dbus/1.0/introspect.dtd">
    <node>
      <interface name="org.freedesktop.DBus.Introspectable">
        <method name="Introspect">
          <arg name="data" direction="out" type="s"/>
        </method>
      </interface>
      <interface name=dbus_method.dbusNotificationsInterface>
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
end)

-- listen for dbus notification requests
capi.dbus.request_name(dbus_connection.session, dbus_method.dbusNotificationsInterface)

-- For testing
dbus._notif_methods = notif_methods

dbus.notification   = function(app_name, title, text, app_icon, urgency)
    notif_methods.Notify({  }, app_name, 0, app_icon, title, text, nil, { urgency = urgency or "normal" }, -1)
end

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
