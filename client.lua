--When a client gains focus.
client.connect_signal("focus", function()
    log:debug("focus")
end)

--Before manage, after unmanage, and when clients swap.
client.connect_signal("list", function()
    log:debug("list")
end)

--When 2 clients are swapped
client.connect_signal("swapped", function(c, is_source)
    log:debug("swapped")
end)
--When a new client appears and gets managed by Awesome.
client.connect_signal("manage", function()
    log:debug("manage")
end)

client.connect_signal("button::press", function()
end)

client.connect_signal("button::release", function()
end)

client.connect_signal("mouse::enter", function()
end)

client.connect_signal("mouse::leave", function()
end)

client.connect_signal("mouse::move", function()
end)

client.connect_signal("property::window", function()
    log:debug("property::window")
end)

--When a client should get activated (focused and/or raised).
client.connect_signal("request::activate", function(context, hints, raise)
    --context string The context where this signal was used.
    --hints A table with additional hints:
    --raise boolean should the client be raised? (default false)
    log:debug("request::activate")
end)

client.connect_signal("request::geometry", function(c, context, Additional)
    --c client The client
    --context string Why and what to resize. This is used for the handlers to know if they are capable of applying the new geometry.
    --Additional table arguments. Each context handler may interpret this differently. (default {})
    log:debug("request::geometry")
end)

client.connect_signal("request::tag", function()
    log:debug("request::tag")
end)

client.connect_signal("request::urgent", function()
    log:debug("request::urgent")
end)

--When a client gets tagged.
client.connect_signal("tagged", function(t)
    --t tag The tag object.
    log:debug("tagged")
end)

--When a client gets unfocused.
client.connect_signal("unfocus", function()
    log:debug("unfocus")
end)

--When a client gets untagged.
client.connect_signal("unmanage", function()
    log:debug("unmanage")
end)

client.connect_signal("untagged", function(t)
    --t tag The tag object.
    log:debug("untagged")
end)

client.connect_signal("raised", function()
    log:debug("raised")
end)

client.connect_signal("lowered", function()
    log:debug("lowered")
end)

--When the height or width changed.
client.connect_signal("property::size", function()
end)

--When the x or y coordinate changed.
client.connect_signal("property::position", function()
end)

--The last geometry when client was floating.
client.connect_signal("property::floating_geometry", function()
end)

--Emited when a client need to get a titlebar.
client.connect_signal("request::titlebars", function(context, hints)
    --content string The context (like “rules”) (default nil)
    --hints table Some hints. (default nil)
end)

--The client marked signal (deprecated).
client.connect_signal("marked", function()
    log:debug("marked")
end)

--The client unmarked signal (deprecated).
client.connect_signal("unmarked", function()
    log:debug("unmarked")
end)
