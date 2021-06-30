local resources = require("resources")

local titlebar  = {}

function titlebar:init(theme)
    theme.titlebars_enabled                               = true

    theme.titlebars_size                                   = 25
    theme.titlebars_position                               = "top"
    theme.titlebars_imitate_borders                        = true

    --[[ MENU ]]--
    theme.titlebar_menu_button_focus                      = resources.titlebar.menu.button_focus
    theme.titlebar_menu_button_focus_hover                = resources.titlebar.menu.button_focus_hover
    theme.titlebar_menu_button_focus_press                = resources.titlebar.menu.button_focus_press

    theme.titlebar_menu_button_normal                     = resources.titlebar.menu.button_normal
    theme.titlebar_menu_button_normal_hover               = resources.titlebar.menu.button_normal_hover
    theme.titlebar_menu_button_normal_press               = resources.titlebar.menu.button_normal_press


    --[[ FLOATING ]]--
    theme.titlebar_floating_button_focus_active           = resources.titlebar.floating.button_focus_active
    theme.titlebar_floating_button_focus_active_hover     = resources.titlebar.floating.button_focus_active_hover
    theme.titlebar_floating_button_focus_active_press     = resources.titlebar.floating.button_focus_active_press
    theme.titlebar_floating_button_focus_inactive         = resources.titlebar.floating.button_focus_inactive
    theme.titlebar_floating_button_focus_inactive_hover   = resources.titlebar.floating.button_focus_inactive_hover
    theme.titlebar_floating_button_focus_inactive_press   = resources.titlebar.floating.button_focus_inactive_press

    theme.titlebar_floating_button_normal_active          = resources.titlebar.floating.button_normal_active
    theme.titlebar_floating_button_normal_active_hover    = resources.titlebar.floating.button_normal_active_hover
    theme.titlebar_floating_button_normal_active_press    = resources.titlebar.floating.button_normal_active_press
    theme.titlebar_floating_button_normal_inactive        = resources.titlebar.floating.button_normal_inactive
    theme.titlebar_floating_button_normal_inactive_hover  = resources.titlebar.floating.button_normal_inactive_hover
    theme.titlebar_floating_button_normal_inactive_press  = resources.titlebar.floating.button_normal_inactive_press


    --[[ MAXIMIZED ]]--
    theme.titlebar_maximized_button_focus_active          = resources.titlebar.maximized.button_focus_active
    theme.titlebar_maximized_button_focus_active_hover    = resources.titlebar.maximized.button_focus_active_hover
    theme.titlebar_maximized_button_focus_active_press    = resources.titlebar.maximized.button_focus_active_press
    theme.titlebar_maximized_button_focus_inactive        = resources.titlebar.maximized.button_focus_inactive
    theme.titlebar_maximized_button_focus_inactive_hover  = resources.titlebar.maximized.button_focus_inactive_hover
    theme.titlebar_maximized_button_focus_inactive_press  = resources.titlebar.maximized.button_focus_inactive_press

    theme.titlebar_maximized_button_normal_active         = resources.titlebar.maximized.button_normal_active
    theme.titlebar_maximized_button_normal_active_hover   = resources.titlebar.maximized.button_normal_active_hover
    theme.titlebar_maximized_button_normal_active_press   = resources.titlebar.maximized.button_normal_active_press
    theme.titlebar_maximized_button_normal_inactive       = resources.titlebar.maximized.button_normal_inactive
    theme.titlebar_maximized_button_normal_inactive_hover = resources.titlebar.maximized.button_normal_inactive_hover
    theme.titlebar_maximized_button_normal_inactive_press = resources.titlebar.maximized.button_normal_inactive_press


    --[[ MINIMIZE ]]--
    theme.titlebar_minimize_button_focus                  = resources.titlebar.minimize.button_focus
    theme.titlebar_minimize_button_focus_hover            = resources.titlebar.minimize.button_focus_hover
    theme.titlebar_minimize_button_focus_press            = resources.titlebar.minimize.button_focus_press

    theme.titlebar_minimize_button_normal                 = resources.titlebar.minimize.button_normal
    theme.titlebar_minimize_button_normal_hover           = resources.titlebar.minimize.button_normal_hover
    theme.titlebar_minimize_button_normal_press           = resources.titlebar.minimize.button_normal_press


    --[[ CLOSE ]]--
    theme.titlebar_close_button_focus                     = resources.titlebar.close.button_focus
    theme.titlebar_close_button_focus_hover               = resources.titlebar.close.button_focus_hover
    theme.titlebar_close_button_focus_press               = resources.titlebar.close.button_focus_press

    theme.titlebar_close_button_normal                    = resources.titlebar.close.button_normal
    theme.titlebar_close_button_normal_hover              = resources.titlebar.close.button_normal_hover
    theme.titlebar_close_button_normal_press              = resources.titlebar.close.button_normal_press


    --[[ ONTOP ]]--
    theme.titlebar_ontop_button_focus                     = resources.titlebar.ontop.button_focus
    theme.titlebar_ontop_button_focus_active              = resources.titlebar.ontop.button_focus_active
    theme.titlebar_ontop_button_focus_active_hover        = resources.titlebar.ontop.button_focus_active_hover
    theme.titlebar_ontop_button_focus_active_press        = resources.titlebar.ontop.button_focus_active_press
    theme.titlebar_ontop_button_focus_inactive            = resources.titlebar.ontop.button_focus_inactive
    theme.titlebar_ontop_button_focus_inactive_hover      = resources.titlebar.ontop.button_focus_inactive_hover
    theme.titlebar_ontop_button_focus_inactive_press      = resources.titlebar.ontop.button_focus_inactive_press
    theme.titlebar_ontop_button_normal                    = resources.titlebar.ontop.button_normal
    theme.titlebar_ontop_button_normal_active             = resources.titlebar.ontop.button_normal_active
    theme.titlebar_ontop_button_normal_active_hover       = resources.titlebar.ontop.button_normal_active_hover
    theme.titlebar_ontop_button_normal_active_press       = resources.titlebar.ontop.button_normal_active_press
    theme.titlebar_ontop_button_normal_inactive           = resources.titlebar.ontop.button_normal_inactive
    theme.titlebar_ontop_button_normal_inactive_hover     = resources.titlebar.ontop.button_normal_inactive_hover
    theme.titlebar_ontop_button_normal_inactive_press     = resources.titlebar.ontop.button_normal_inactive_press


    -- [[ STICKY ]]--
    theme.titlebar_sticky_button_normal                   = resources.titlebar.sticky.button_normal
    theme.titlebar_sticky_button_focus                    = resources.titlebar.sticky.button_focus
    theme.titlebar_sticky_button_normal_active            = resources.titlebar.sticky.button_normal_active
    theme.titlebar_sticky_button_normal_active_hover      = resources.titlebar.sticky.button_normal_active_hover
    theme.titlebar_sticky_button_normal_active_press      = resources.titlebar.sticky.button_normal_active_press
    theme.titlebar_sticky_button_focus_active             = resources.titlebar.sticky.button_focus_active
    theme.titlebar_sticky_button_focus_active_hover       = resources.titlebar.sticky.button_focus_active_hover
    theme.titlebar_sticky_button_focus_active_press       = resources.titlebar.sticky.button_focus_active_press
    theme.titlebar_sticky_button_normal_inactive          = resources.titlebar.sticky.button_normal_inactive
    theme.titlebar_sticky_button_normal_inactive_hover    = resources.titlebar.sticky.button_normal_inactive_hover
    theme.titlebar_sticky_button_normal_inactive_press    = resources.titlebar.sticky.button_normal_inactive_press
    theme.titlebar_sticky_button_focus_inactive           = resources.titlebar.sticky.button_focus_inactive
    theme.titlebar_sticky_button_focus_inactive_hover     = resources.titlebar.sticky.button_focus_inactive_hover
    theme.titlebar_sticky_button_focus_inactive_press     = resources.titlebar.sticky.button_focus_inactive_press
end

return setmetatable(titlebar, { __call = function(_, ...)
    return titlebar:init(...)
end })