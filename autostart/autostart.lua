local autostart = {}

local awful     = require("awful")

function autostart.list()
    return {
        "gxkb",
        "nm-applet",
        "blueman-applet",
        "flameshot",
        --"sudo solaar" -- only sudo
        --"megasync",
        --"indicator-stickynotes"
    }
end

function autostart:start()
    for i, it in pairs(autostart.list()) do
        local cmd        = tostring(it)
        local findme     = cmd
        local firstspace = cmd:find(" ")

        if firstspace then
            findme = cmd:sub(0, firstspace - 1)
        end

        awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))
    end
end

return autostart