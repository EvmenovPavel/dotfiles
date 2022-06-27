local beautiful = require("beautiful")

local theme     = require("theme")

theme:theme(beautiful)
theme:titlebar(beautiful)
theme:taglist(beautiful)
theme:tasklist(beautiful)
theme:menu(beautiful)
theme:wibar(beautiful)

function print(...)
    -- log:debug("print:", ...)
end

local keybinds = require("keys.keybinds")
root.keys(keybinds.globalkeys)
root.buttons(keybinds.buttonkeys)

local awful       = require("awful")
awful.rules.rules = require("rules")(keybinds.clientkeys, keybinds.buttonkeys)

local apps        = require("autostart")
apps:start()

require("modules.titlebar")
local wibar     = require("wibar")
local wallpaper = require("modules.wallpaper")

awful.screen.connect_for_each_screen(
        function(s)
            wallpaper(s)
            wibar(s)

            for i, icon in pairs(beautiful.taglist_icons) do
                awful.tag.add(i, {
                    icon      = icon,
                    icon_only = true,
                    layout    = awful.layout.suit.tile,
                    screen    = s,
                    selected  = i == 1
                })
            end
        end
)

require("awful.autofocus")
local fun = require("functions")

client.connect_signal("focus",
                      function(c)
                          c.border_color = beautiful.bg_focus
                          c:raise()
                      end)

client.connect_signal("unfocus",
                      function(c)
                          if c.maximized or c.fullscreen then
                              c.border_color = beautiful.border_normal
                          else
                              c.border_color = color.disabled_inner
                          end

                          c:raise()
                      end)

--window 	The X window id.
--name 	The client title.
--skip_taskbar 	True if the client does not want to be in taskbar.
--type 	The window type.
--class 	The client class.
--instance 	The client instance.
--pid 	The client PID, if available.
--role 	The window role, if available.
--machine 	The machine client is running on.
--icon_name 	The client name when iconified.
--icon 	The client icon as a surface.
--icon_sizes 	The available sizes of client icons.
--screen 	Client screen.
--hidden 	Define if the client must be hidden, i.e.
--minimized 	Define it the client must be iconify, i.e.
--size_hints_honor 	Honor size hints, e.g.
--border_width 	The client border width.
--border_color 	The client border color.
--urgent 	The client urgent state.
--content 	A cairo surface for the client window content.
--opacity 	The client opacity.
--ontop 	The client is on top of every other windows.
--above 	The client is above normal windows.
--below 	The client is below normal windows.
--fullscreen 	The client is fullscreen or not.
--maximized 	The client is maximized (horizontally and vertically) or not.
--maximized_horizontal 	The client is maximized horizontally or not.
--maximized_vertical 	The client is maximized vertically or not.
--transient_for 	The client the window is transient for.
--group_window 	Window identification unique to a group of windows.
--leader_window 	Identification unique to windows spawned by the same command.
--size_hints 	A table with size hints of the client.
--motif_wm_hints 	The motif WM hints of the client.
--sticky 	Set the client sticky, i.e.
--modal 	Indicate if the client is modal.
--focusable 	True if the client can receive the input focus.
--shape_bounding 	The client’s bounding shape as set by awesome as a (native) cairo surface.
--shape_clip 	The client’s clip shape as set by awesome as a (native) cairo surface.
--shape_input 	The client’s input shape as set by awesome as a (native) cairo surface.
--client_shape_bounding 	The client’s bounding shape as set by the program as a (native) cairo surface.
--client_shape_clip 	The client’s clip shape as set by the program as a (native) cairo surface.
--startup_id 	The FreeDesktop StartId.
--valid 	If the client that this object refers to is still managed by awesome.
--first_tag 	The first tag of the client.
--marked 	If a client is marked or not.
--is_fixed 	Return if a client has a fixed size or not.
--immobilized 	Is the client immobilized horizontally?
--immobilized 	Is the client immobilized vertically?
--floating 	The client floating state.
--x 	The x coordinates.
--y 	The y coordinates.
--width 	The width of the client.
--height 	The height of the client.
--dockable 	If the client is dockable.
--requests_no_titlebar 	If the client requests not to be decorated with a titlebar.
--shape 	Set the client shape.

----When a client gains focus.
--client.connect_signal("focus", function(c)
--    log:debug("focus")
--    -- fun:logs(c)
--end)
--
----Before manage, after unmanage, and when clients swap.
--client.connect_signal("list", function(c)
--    log:debug("list")
--    -- fun:logs(c)
--end)
--
----When 2 clients are swapped
--client.connect_signal("swapped", function(c, is_source)
--    log:debug("swapped")
--    -- fun:logs(c)
--end)
--
----When a new client appears and gets managed by Awesome.
--client.connect_signal("manage", function(c)
--    log:debug("manage")
--    -- fun:logs(c)
--end)
--
--client.connect_signal("property::window", function(c)
--    log:debug("property::window")
--    -- fun:logs(c)
--end)
--
----When a client should get activated (focused and/or raised).
--client.connect_signal("request::activate", function(context, hints, raise)
--    --context string The context where this signal was used.
--    --hints A table with additional hints:
--    --raise boolean should the client be raised? (default false)
--    log:debug("request::activate")
--    -- fun:logs(c)
--end)
--
--client.connect_signal("request::geometry", function(c, context, Additional)
--    --c client The client
--    --context string Why and what to resize. This is used for the handlers to know if they are capable of applying the new geometry.
--    --Additional table arguments. Each context handler may interpret this differently. (default {})
--    log:debug("request::geometry")
--    -- fun:logs(c)
--end)
--
--client.connect_signal("request::tag", function(c)
--    log:debug("request::tag")
--    -- fun:logs(c)
--end)
--
--client.connect_signal("request::urgent", function(c)
--    log:debug("request::urgent")
--    -- fun:logs(c)
--end)
--
----When a client gets tagged.
--client.connect_signal("tagged", function(c)
--    --t tag The tag object.
--    log:debug("tagged")
--    -- fun:logs(c)
--end)
--
----When a client gets unfocused.
--client.connect_signal("unfocus", function(c)
--    log:debug("unfocus")
--    -- fun:logs(c)
--end)
--
----When a client gets untagged.
--client.connect_signal("unmanage", function(c)
--    log:debug("unmanage")
--    -- fun:logs(c)
--end)
--
--client.connect_signal("untagged", function(c)
--    --t tag The tag object.
--    log:debug("untagged")
--    -- fun:logs(c)
--end)
--
--client.connect_signal("raised", function(c)
--    log:debug("raised")
--    -- fun:logs(c)
--end)
--
--client.connect_signal("lowered", function(c)
--    log:debug("lowered")
--    -- fun:logs(c)
--end)
--
----When the height or width changed.
--client.connect_signal("property::size", function(c)
--    log:debug("property::size")
--    -- так же
--    -- fun:logs(c)
--end)
--
----When the x or y coordinate changed.
--client.connect_signal("property::position", function(c)
--    log:debug("property::position")
--    -- тут обо обновило
--    -- но, добавила грани
--    --fun:update_client(c)
--    -- fun:logs(c)
--end)
--
----The last geometry when client was floating.
--client.connect_signal("property::floating_geometry", function(c)
--    log:debug("property::floating_geometry")
--    -- fun:logs(c)
--end)
--
----Emited when a client need to get a titlebar.
--client.connect_signal("request::titlebars", function(context, hints)
--    --content string The context (like “rules”) (default nil)
--    --hints table Some hints. (default nil)
--end)
--
----The client marked signal (deprecated).
--client.connect_signal("marked", function(c)
--    log:debug("marked")
--    -- fun:logs(c)
--end)
--
----The client unmarked signal (deprecated).
--client.connect_signal("unmarked", function(c)
--    log:debug("unmarked")
--    -- fun:logs(c)
--end)
