--Wed Sep 16 15:37:33 2020
--nil: Album        Ghost in the Shell (Music Inspired by the Motion Picture)
--AlbumArtist  Various Artists
--Artist       DJ Shadow
--Title        Scars



local awful                  = require("awful")
local spawn                  = require("awful.spawn")
local wibox                  = require("wibox")
local gears                  = require("gears")
local beautiful              = require("beautiful")
local dpi                    = require("beautiful").xresources.apply_dpi
local watch                  = require("awful.widget.watch")
local separator              = require("widgets.separator.separator")
local mouse                  = require("event").mouse

local GET_SPOTIFY_STATUS_CMD = "sp status"
local GET_CURRENT_SONG_CMD   = "sp current"

local pathIcon               = capi.path .. "/widgets/spotify"

local icons                  = {
    logo  = pathIcon .. "/spotify.svg",
    play  = pathIcon .. "/player_play.png",
    pause = pathIcon .. "/player_pause.png",
    stop  = pathIcon .. "/player_stop.png",
    next  = pathIcon .. "/player_fwd.png",
    prev  = pathIcon .. "/player_rew.png",
}

local myspotify              = {}

local cur_artist             = ""
local cur_title              = ""
local cur_album              = ""

local widget_icon            = wibox.widget {
    {
        id     = "icon",
        image  = icons.logo,
        widget = wibox.widget.imagebox,
        resize = true
    },
    layout = wibox.layout.align.horizontal
}

local widget_spotify         = capi.wmapi:container(wibox.container.margin(widget_icon, dpi(7), dpi(7), dpi(7), dpi(7)))

local function create_widget_icon(image, command)
    local command = command or nil
    local widget  = wibox.widget {
        id     = "icon",
        image  = image,
        height = 24,
        width  = 24,
        widget = wibox.widget.imagebox,
        resize = true
    }

    if command then
        widget:buttons(
                gears.table.join(
                        awful.button({}, mouse.button_click_left, nil,
                                     function()
                                         awful.spawn(command, false)
                                     end
                        )
                )
        )
    end

    return widget
end

local function create_widget_text(text)
    local widget = wibox.widget {
        margin = text,
        widget = wibox.widget.textbox,
    }

    return widget
end

local prev  = create_widget_icon(icons.prev, "sp prev")
local pause = create_widget_icon(icons.stop, "sp stop")
local play  = create_widget_icon(icons.play, "sp play")
local next  = create_widget_icon(icons.next, "sp next")

local text  = create_widget_text("")

function myspotify:w_left()
    return {
        capi.wmapi:container(prev),
        capi.wmapi:container(play),
        --capi.wmapi:container(pause),
        capi.wmapi:container(next),

        layout = wibox.layout.fixed.horizontal
    }
end

function myspotify:w_middle()
    return {
        text,
        layout = wibox.layout.fixed.horizontal
    }
end

function myspotify:w_right()
    return {
        layout = wibox.layout.fixed.horizontal
    }
end

--print(os.getenv("HOSTNAME") or os.getenv("HOST"))

function myspotify:init(s)
    widget_spotify.spotify = awful.wibar({
                                             screen       = s,
                                             ontop        = false,
                                             stretch      = true,
                                             position     = beautiful.position.button,
                                             border_width = 0,
                                             visible      = true,
                                             height       = 27,
                                             width        = capi.wmapi.screen_width - 30,
                                         })

    widget_spotify.spotify:setup {
        self:w_left(s),
        self:w_middle(s),
        self:w_right(s),
        layout = wibox.layout.align.horizontal,
    }

    capi.wmapi:update(0.1,
                      function()
                          spawn.easy_async(GET_SPOTIFY_STATUS_CMD, function(stdout)
                              stdout = string.gsub(stdout, "\n", "")

                              if stdout == "Playing" then
                                  play:set_image(icons.pause)
                              elseif stdout == "Paused" then
                                  play:set_image(icons.play)
                              end

                              widget_spotify.spotify.visible = stdout == "Playing" or stdout == "Paused"
                          end)

                          spawn.easy_async(GET_CURRENT_SONG_CMD,
                                           function(stdout)
                                               stdout                                   = string.gsub(stdout, "&", "&amp;")
                                               local album, album_artist, artist, title = string.match(stdout, "Album%s*(.*)\nAlbumArtist%s*(.*)\nArtist%s*(.*)\nTitle%s*(.*)\n")

                                               if album ~= nil and title ~= nil and artist ~= nil then
                                                   cur_artist = artist
                                                   cur_title  = title
                                                   cur_album  = album

                                                   local t    = "Artist: " .. cur_artist .. " - " .. cur_title .. " [Album: " .. cur_album .. "]"

                                                   text:set_text(t)
                                               end
                                           end)
                      end)

    capi.awesome.connect_signal("spotify_change",
                                function()

                                end
    )

    widget_spotify:buttons(
            gears.table.join(
                    awful.button({}, mouse.button_click_left, nil,
                                 function()
                                     widget_spotify.spotify.visible = not widget_spotify.spotify.visible
                                 end
                    )
            )
    )

    --return widget_spotify
end

return setmetatable(myspotify, {
    __call = myspotify.init,
})
