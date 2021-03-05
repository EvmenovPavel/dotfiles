local awful                  = require("awful")
local wibox                  = require("wibox")

local GET_SPOTIFY_STATUS_CMD = "sp status"
local GET_CURRENT_SONG_CMD   = "sp current"

local function ellipsize(text, length)
    return (text:len() > length and length > 0)
            and text:sub(0, length - 3) .. "..."
            or text
end

local myspotify = {}

function myspotify:init(s)
    --local play_icon       = "/usr/share/icons/gnome/24x24/actions/player_play.png"
    --local pause_icon      = "/usr/share/icons/gnome/24x24/actions/player_pause.png"
    --local font            = beautiful.font
    --local dim_when_paused = nil
    --local dim_opacity     = 0.2
    --local max_length      = 30
    --local show_tooltip    = nil
    --
    --local cur_artist      = ""
    --local cur_title       = ""
    --local cur_album       = ""

    local spotify = awful.wibar({
                                    ontop        = false,
                                    stretch      = true,
                                    position     = "bottom",
                                    border_width = 0,
                                    visible      = true,
                                    height       = 27,
                                    width        = wmapi.screen_width - 30,
                                    --screen       = s,
                                })

    spotify:setup {
        --self:w_left(s),
        --self:w_middle(s),
        --self:w_right(s),
        layout = wibox.layout.align.vertical,
    }

    --local spotify            = wibox.widget {
    --    {
    --        id     = "icon",
    --        widget = wibox.widget.imagebox,
    --    },
    --    {
    --        id     = "artistw",
    --        font   = font,
    --        widget = wibox.widget.textbox,
    --    },
    --    {
    --        id     = "titlew",
    --        font   = font,
    --        widget = wibox.widget.textbox
    --    },
    --    layout     = wibox.layout.align.horizontal,
    --    set_status = function(self, is_playing)
    --        self.icon.image = (is_playing and pause_icon or play_icon)
    --        if dim_when_paused then
    --            self.icon.opacity = (is_playing and 1 or dim_opacity)
    --
    --            self.titlew:set_opacity(is_playing and 1 or dim_opacity)
    --            self.titlew:emit_signal("widget::redraw_needed")
    --
    --            self.artistw:set_opacity(is_playing and 1 or dim_opacity)
    --            self.artistw:emit_signal("widget::redraw_needed")
    --        end
    --    end,
    --    set_text   = function(self, artist, song)
    --        local artist_to_display = artist--ellipsize(artist, max_length)
    --        if self.artistw.text ~= artist_to_display then
    --            self.artistw.text = artist_to_display
    --        end
    --        local title_to_display = song--ellipsize(song, max_length)
    --        if self.titlew.text ~= title_to_display then
    --            self.titlew.text = title_to_display
    --        end
    --    end
    --}
    --
    --local update_widget_icon = function(widget, stdout, _, _, _)
    --    stdout = string.gsub(stdout, "\n", "")
    --    widget:set_status(stdout == "Playing" and true or false)
    --end
    --
    --local update_widget_text = function(widget, stdout, _, _, _)
    --    if string.find(stdout, "Error: Spotify is not running.") ~= nil then
    --        widget:set_text("", "")
    --        widget:set_visible(false)
    --        return
    --    end
    --
    --    local escaped                            = string.gsub(stdout, "&", "&amp;")
    --
    --    local album, album_artist, artist, title = string.match(escaped, "Album%s*(.*)\nAlbumArtist%s*(.*)\nArtist%s*(.*)\nTitle%s*(.*)\n")
    --
    --    if album ~= nil and title ~= nil and artist ~= nil then
    --        cur_artist = artist .. " " .. album_artist
    --        cur_title  = title
    --        cur_album  = album
    --
    --        widget:set_text(artist .. " - ", title)
    --        widget:set_visible(true)
    --    end
    --end
    --
    --watch(GET_SPOTIFY_STATUS_CMD, 0.5, update_widget_icon, spotify)
    --watch(GET_CURRENT_SONG_CMD, 0.5, update_widget_text, spotify)
    --
    ----- Adds mouse controls to the widget:
    ----  - left click - play/pause
    ----  - scroll up - play next song
    ----  - scroll down - play previous song
    --spotify:connect_signal("button::press", function(_, _, _, button)
    --    if (button == 1) then
    --        awful.spawn("sp play", false)  -- left click
    --    elseif (button == 4) then
    --        awful.spawn("sp next", false)  -- scroll up
    --    elseif (button == 5) then
    --        awful.spawn("sp prev", false)  -- scroll down
    --    end
    --    awful.spawn.easy_async(GET_SPOTIFY_STATUS_CMD, function(stdout, stderr, exitreason, exitcode)
    --        update_widget_icon(spotify, stdout, stderr, exitreason, exitcode)
    --    end)
    --end)
    --
    --if show_tooltip then
    --    local spotify_tooltip = awful.tooltip {
    --        mode                = "outside",
    --        preferred_positions = { "bottom" },
    --    }
    --
    --    spotify_tooltip:add_to_object(spotify)
    --
    --    spotify:connect_signal("mouse::enter",
    --                           function()
    --                               spotify_tooltip.markup = "<b>Album</b>: " .. cur_album
    --                                       .. " - "
    --                                       .. "\n<b>Artist</b>: " .. cur_artist
    --                                       .. " - "
    --                                       .. "\n<b>Song</b>: " .. cur_title
    --                           end)
    --end

    return spotify
end

return setmetatable(myspotify, {
    __call = myspotify.init,
})
