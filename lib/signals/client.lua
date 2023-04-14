-- When a client gains focus.
-- Когда клиент фокусируется.
client.connect_signal("focus", function(c)
	log:debug("focus")
end)

-- Before manage, after unmanage, and when clients swap.
-- Перед управлением, после отказа от управления и при обмене клиентами.
client.connect_signal("list", function(c)
	log:debug("list")
end)

-- When 2 clients are swapped.
-- Когда 2 клиента поменялись местами.
client.connect_signal("swapped", function(c)
	log:debug("swapped")
end)

-- When a new client appears and gets managed by Awesome.
-- Когда появляется новый клиент, которым управляет Awesome.
client.connect_signal("manage", function(c)
	log:debug("manage")
end)

client.connect_signal("button::press", function(c)
	log:debug("button::press")
end) --

client.connect_signal("button::release", function(c)
	log:debug("button::release")
end) --

client.connect_signal("mouse::enter", function(c)
	--log:debug("mouse::enter")
end) --

client.connect_signal("mouse::leave", function(c)
	--log:debug("mouse::leave")
end) --

client.connect_signal("mouse::move", function(c)
	--log:debug("mouse::move")
end) --

client.connect_signal("property::window", function(c)
	log:debug("property::window")
end) --

-- When a client should get activated (focused and/or raised).
-- Когда клиент должен активироваться (сфокусироваться и/или подняться).
client.connect_signal("request::activate", function(c)
	log:debug("request::activate")
end)

client.connect_signal("request::geometry", function(c)
	log:debug("request::geometry")
end) --

client.connect_signal("request::tag", function(c)
	log:debug("request::tag")
end) --

client.connect_signal("request::urgent", function(c)
	log:debug("request::urgent")
end) --

-- When a client gets tagged.
-- Когда клиент получает тег.
client.connect_signal("tagged", function(c)
	log:debug("tagged")
end)

-- When a client gets unfocused.
-- Когда клиент теряет фокус.
client.connect_signal("unfocus", function(c)
	log:debug("unfocus")
end)

client.connect_signal("unmanage", function(c)
	log:debug("unmanage")
end) --

-- When a client gets untagged.
-- Когда клиент становится немаркированным.
client.connect_signal("untagged", function(c)
	log:debug("untagged")
end)

client.connect_signal("raised", function(c)
	log:debug("raised")
end) --

client.connect_signal("lowered", function(c)
	log:debug("lowered")
end) --

-- When the height or width changed.
-- При изменении высоты или ширины.
client.connect_signal("property::size", function(c)
	log:debug("property::size")
end)

-- When the x or y coordinate changed.
-- При изменении координаты x или y.
client.connect_signal("property::position", function(c)
	log:debug("property::position")
end)

-- The last geometry when client was floating.
-- Последняя геометрия, когда клиент был плавающим.
client.connect_signal("property::floating_geometry", function(c)
	log:debug("property::floating_geometry")
end)

-- Emited when a client need to get a titlebar.
-- Генерируется, когда клиенту нужно получить строку заголовка.
client.connect_signal("request::titlebars", function(c)
	log:debug("request::titlebars")
end)

-- The client marked signal (deprecated).
-- Помеченный клиентом сигнал (устаревший).
client.connect_signal("marked", function(c)
	log:debug("marked")
end)

-- The client unmarked signal (deprecated).
-- Сигнал клиента без пометки (устаревший).
client.connect_signal("unmarked", function(c)
	log:debug("unmarked")
end)
