screen.connect_signal("primary_changed", function()
    --log:debug("screen:primary_changed")
end)
-- спрабатывает, когда добавляется скрин
-- This signal is emitted when a new screen is added to the current setup.
screen.connect_signal("added", function()
    --log:debug("screen:added")
end)
-- спрабатывает, когда удаляется скрин
-- This signal is emitted when a screen is removed from the setup.
screen.connect_signal("removed", function()
    --log:debug("screen:removed")
end)
-- This signal is emitted when the list of available screens changes.
screen.connect_signal("list", function()
    --log:debug("screen:list")
end)
-- When 2 screens are swapped
screen.connect_signal("swapped", function()
    --log:debug("screen:swapped")
end)
-- When the tag history changed.
screen.connect_signal("tag::history::update", function()
    --log:debug("screen:tag::history::update")
end)