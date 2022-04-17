local menu      = {}

function menu:init(theme)
    theme.menu_submenu_icon = resources.awesome
    theme.menu_height       = 40
    theme.menu_width        = 140
    --theme.menu_bg_normal    = theme.colors.menu.normal[1]
    --theme.menu_fg_normal    = theme.colors.menu.normal[2]
    --theme.menu_bg_focus     = theme.colors.menu.focus[1]
    --theme.menu_fg_focus     = theme.colors.menu.focus[2]
    --theme.menu_bg_urgent    = theme.colors.menu.urgent[1]
    --theme.menu_fg_urgent    = theme.colors.menu.urgent[2]
    --theme.menu_border_color = theme.colors.menu.border
    theme.menu_border_width = 1
end

return setmetatable(menu, { __call = function(_, ...)
    return menu:init(...)
end })