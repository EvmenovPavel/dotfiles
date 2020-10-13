local taglist       = {}

local taglist_icons = {
    {
        icon = capi.path .. "/icons/tags/terminal.png",
    },
    {
        icon = capi.path .. "/icons/tags/firefox.png",
    },
    {
        icon = capi.path .. "/icons/tags/notepad.png",
    },
    {
        icon = capi.path .. "/icons/tags/folder.png",
    },
    {
        icon = capi.path .. "/icons/tags/player.png",
    },
    {
        icon = capi.path .. "/icons/tags/videogame.png",
    },
    {
        icon = capi.path .. "/icons/tags/star.png",
    },
    {
        icon = capi.path .. "/icons/tags/mail.png",
    },
    {
        icon = capi.path .. "/icons/tags/spotify.png",
    }
}

function taglist:init(theme)
    theme.taglist_disable_icon = false

    theme.taglist_count        = 10

    --отспут между item
    theme.taglist_spacing      = 0

    -- Taglist
    theme.taglist_bg_empty     = theme.bg_normal
    theme.taglist_bg_occupied  = "#ffffff1a"
    theme.taglist_bg_urgent    = "#e91e6399"
    theme.taglist_bg_focus     = theme.bg_focus

    theme.taglist_icons        = taglist_icons
end

return setmetatable(taglist, { __call = function(_, ...)
    return taglist:init(...)
end })