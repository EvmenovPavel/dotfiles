screen.connect_signal("primary_changed", function()
<<<<<<< HEAD
    --log:debug("screen:primary_changed")
=======
    --capi.log:message("screen:primary_changed")
>>>>>>> dev_laptop
end)
-- спрабатывает, когда добавляется скрин
-- This signal is emitted when a new screen is added to the current setup.
screen.connect_signal("added", function()
<<<<<<< HEAD
    --log:debug("screen:added")
=======
    --capi.log:message("screen:added")
>>>>>>> dev_laptop
end)
-- спрабатывает, когда удаляется скрин
-- This signal is emitted when a screen is removed from the setup.
screen.connect_signal("removed", function()
<<<<<<< HEAD
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
=======
    --capi.log:message("screen:removed")
end)
-- This signal is emitted when the list of available screens changes.
screen.connect_signal("list", function()
    --capi.log:message("screen:list")
end)
-- When 2 screens are swapped
screen.connect_signal("swapped", function()
    --capi.log:message("screen:swapped")
end)
-- When the tag history changed.
screen.connect_signal("tag::history::update", function()
    --capi.log:message("screen:tag::history::update")
>>>>>>> dev_laptop
end)