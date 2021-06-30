-- Keyboard layout switcher
local wibox = require("lib.wibox")

return function(theme)
    local keyboard                  = {}

    -- Keyboard layout switcher
    keyboard.kbdwidget              = wibox.widget.textbox()
    keyboard.kbdwidget.border_width = 1
    keyboard.kbdwidget.border_color = "#232323"
    keyboard.kbdwidget.font         = theme.font
    keyboard.kbdwidget:set_markup("<span foreground='#232323'> Eng </span>")

    keyboard.kbdstrings = { [0] = " Eng ",
                            [1] = " Rus " }

    keyboard.dbus.request_name("session", "ru.gentoo.kbdd")
    keyboard.dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
    keyboard.dbus.connect_signal("ru.gentoo.kbdd",
                                 function(...)
                                     local data   = { ... }
                                     local layout = data[2]
                                     keyboard.kbdwidget:set_markup("<span foreground='#232323'>" .. keyboard.kbdstrings[layout] .. "</span>")
                                 end
    )

    return keyboard
end