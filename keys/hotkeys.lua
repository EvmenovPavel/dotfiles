local hotkeys = {}

hotkeys       = {
    awesome   = {
        show    = { description = "show help", group = "awesome" },
        restart = { description = "restart awesome", group = "awesome" },
        quit    = { description = "quit awesome", group = "awesome" },
        help    = { description = "help awesome", group = "awesome" },
    },

    client    = {
        fullscreen = { description = "toggle maximized", group = "client" },
        maximized  = { description = "toggle maximized", group = "client" },
        minimized  = { description = "toggle maximized", group = "client" },
        kill       = { description = "toggle maximized", group = "client" },
        ontop      = { description = "toggle maximized", group = "client" },
        floating   = { description = "toggle maximized", group = "client" },
        visible    = { description = "toggle maximized", group = "client" },
        previous   = { description = "go back", group = "client" }
    },

    audacious = {
        play = { description = "Pause if playing, play otherwise.", group = "Audacious" },
        next = { description = "Skip forward in playlist.", group = "Audacious" },
        prev = { description = "Skip backwards in playlist.", group = "Audacious" },

    },

    tag       = {
        view           = { description = "view tag #", group = "tag" },
        toggle         = { description = "toggle tag #", group = "tag" },
        move           = { description = "move focused client to tag #", group = "tag" },
        toggle_focused = { description = "toggle focused client on tag #", group = "tag" },

        previous       = { description = "view previous", group = "tag" },
        next           = { description = "view next", group = "tag" },
        restore        = { description = "go back", group = "tag" },

    },

    programm  = {
        manager    = { description = "Open manager", group = "Programms" },
        run        = { description = "Open run window", group = "Programms" },
        terminal   = { description = "Open a terminal", group = "Programms" },
        lockscreen = { description = "Open a terminal", group = "Programms" },

    },

    command   = {
        test        = { description = "test", group = "test" },
        htop        = { description = "htop", group = "Awesome" },
        printscreen = { description = "Printscreen", group = "awesome" },

    },
}

return hotkeys