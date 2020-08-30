local config   = require("config")

local taglist  = {}

local taglist_icons = {
    {
        icon = config.icons .. "/tags/terminal.png",
    },
    {
        icon = config.icons .. "/tags/firefox.png",
    },
    {
        icon = config.icons .. "/tags/notepad.png",
    },
    {
        icon = config.icons .. "/tags/folder.png",
    },
    {
        icon = config.icons .. "/tags/player.png",
    },
    {
        icon = config.icons .. "/tags/videogame.png",
    },
    {
        icon = config.icons .. "/tags/star.png",
    },
    {
        icon = config.icons .. "/tags/mail.png",
    },
    {
        icon = config.icons .. "/tags/spotify.png",
    }
}

function taglist:init(theme)
    theme.taglist_disable_icon = false
    --отспут между item
    theme.taglist_spacing      = 0
    --t.taglist_item_roundness = config.item_roundness
    theme.taglist_font         = config.font

    -- Taglist
    theme.taglist_bg_empty     = theme.bg_normal
    theme.taglist_bg_occupied  = "#ffffff1a"
    theme.taglist_bg_urgent    = "#e91e6399"
    theme.taglist_bg_focus     = theme.bg_focus

    theme.taglist_icons        = taglist_icons

    --The unselected elements background image.
    --taglist.taglist_squares_unsel
    --The selected empty elements background image.
    --taglist.taglist_squares_sel_empty
    --The unselected empty elements background image.
    --taglist.taglist_squares_unsel_empty

    --theme.taglist_bg_focus     = "#000000"
    -- (панель) текст акт в (тег меню)
    --theme.taglist_fg_focus     = "#000000"
    --theme.taglist_bg_empty     = "#000000"
    -- (панель) текст не акт + нету апп (тег меню)
    --theme.taglist_fg_empty     = "#ff0000"
    -- меняет бекграунд окна в котором есть апп, но не акт
    --theme.taglist_bg_occupied  = "#ff00ff"
    -- меняет цвет текста, в окне, которое актив
    --theme.taglist_fg_occupied  = "#ffffff"
    -- меняет бекграунд окна, в котором пришло уведомление
    --theme.taglist_bg_urgent    = "#000000"
    --theme.taglist_fg_urgent    = "#ffffff"
end

return setmetatable(taglist, { __call = function(_, ...)
    return taglist:init(...)
end })