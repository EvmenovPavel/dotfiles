local titlebar = {}

function titlebar:init(config)
	config.titlebars_enabled                               = true

	config.titlebars_size                                  = 25
	config.titlebars_position                              = "top"
	config.titlebars_imitate_borders                       = true

	--[[ MENU ]]--
	config.titlebar_menu_button_focus                      = resources.titlebar.menu.button_focus
	config.titlebar_menu_button_focus_hover                = resources.titlebar.menu.button_focus_hover
	config.titlebar_menu_button_focus_press                = resources.titlebar.menu.button_focus_press

	config.titlebar_menu_button_normal                     = resources.titlebar.menu.button_normal
	config.titlebar_menu_button_normal_hover               = resources.titlebar.menu.button_normal_hover
	config.titlebar_menu_button_normal_press               = resources.titlebar.menu.button_normal_press


	--[[ FLOATING ]]--
	config.titlebar_floating_button_focus_active           = resources.titlebar.floating.button_focus_active
	config.titlebar_floating_button_focus_active_hover     = resources.titlebar.floating.button_focus_active_hover
	config.titlebar_floating_button_focus_active_press     = resources.titlebar.floating.button_focus_active_press
	config.titlebar_floating_button_focus_inactive         = resources.titlebar.floating.button_focus_inactive
	config.titlebar_floating_button_focus_inactive_hover   = resources.titlebar.floating.button_focus_inactive_hover
	config.titlebar_floating_button_focus_inactive_press   = resources.titlebar.floating.button_focus_inactive_press

	config.titlebar_floating_button_normal_active          = resources.titlebar.floating.button_normal_active
	config.titlebar_floating_button_normal_active_hover    = resources.titlebar.floating.button_normal_active_hover
	config.titlebar_floating_button_normal_active_press    = resources.titlebar.floating.button_normal_active_press
	config.titlebar_floating_button_normal_inactive        = resources.titlebar.floating.button_normal_inactive
	config.titlebar_floating_button_normal_inactive_hover  = resources.titlebar.floating.button_normal_inactive_hover
	config.titlebar_floating_button_normal_inactive_press  = resources.titlebar.floating.button_normal_inactive_press


	--[[ MAXIMIZED ]]--
	config.titlebar_maximized_button_focus_active          = resources.titlebar.maximized.button_focus_active
	config.titlebar_maximized_button_focus_active_hover    = resources.titlebar.maximized.button_focus_active_hover
	config.titlebar_maximized_button_focus_active_press    = resources.titlebar.maximized.button_focus_active_press
	config.titlebar_maximized_button_focus_inactive        = resources.titlebar.maximized.button_focus_inactive
	config.titlebar_maximized_button_focus_inactive_hover  = resources.titlebar.maximized.button_focus_inactive_hover
	config.titlebar_maximized_button_focus_inactive_press  = resources.titlebar.maximized.button_focus_inactive_press

	config.titlebar_maximized_button_normal_active         = resources.titlebar.maximized.button_normal_active
	config.titlebar_maximized_button_normal_active_hover   = resources.titlebar.maximized.button_normal_active_hover
	config.titlebar_maximized_button_normal_active_press   = resources.titlebar.maximized.button_normal_active_press
	config.titlebar_maximized_button_normal_inactive       = resources.titlebar.maximized.button_normal_inactive
	config.titlebar_maximized_button_normal_inactive_hover = resources.titlebar.maximized.button_normal_inactive_hover
	config.titlebar_maximized_button_normal_inactive_press = resources.titlebar.maximized.button_normal_inactive_press


	--[[ MINIMIZE ]]--
	config.titlebar_minimize_button_focus                  = resources.titlebar.minimize.button_focus
	config.titlebar_minimize_button_focus_hover            = resources.titlebar.minimize.button_focus_hover
	config.titlebar_minimize_button_focus_press            = resources.titlebar.minimize.button_focus_press

	config.titlebar_minimize_button_normal                 = resources.titlebar.minimize.button_normal
	config.titlebar_minimize_button_normal_hover           = resources.titlebar.minimize.button_normal_hover
	config.titlebar_minimize_button_normal_press           = resources.titlebar.minimize.button_normal_press


	--[[ CLOSE ]]--
	config.titlebar_close_button_focus                     = resources.titlebar.close.button_focus
	config.titlebar_close_button_focus_hover               = resources.titlebar.close.button_focus_hover
	config.titlebar_close_button_focus_press               = resources.titlebar.close.button_focus_press
	config.titlebar_close_button_focus_inactive            = resources.titlebar.close.button_focus_inactive
	config.titlebar_close_button_focus_inactive_hover      = resources.titlebar.close.button_focus_inactive_hover
	config.titlebar_close_button_focus_inactive_press      = resources.titlebar.close.button_focus_inactive_press

	config.titlebar_close_button_normal                    = resources.titlebar.close.button_normal
	config.titlebar_close_button_normal_hover              = resources.titlebar.close.button_normal_hover
	config.titlebar_close_button_normal_press              = resources.titlebar.close.button_normal_press
	config.titlebar_close_button_normal_inactive           = resources.titlebar.close.button_normal_inactive
	config.titlebar_close_button_normal_inactive_hover     = resources.titlebar.close.button_normal_inactive_hover
	config.titlebar_close_button_normal_inactive_press     = resources.titlebar.close.button_normal_inactive_press


	--[[ ONTOP ]]--
	config.titlebar_ontop_button_focus                     = resources.titlebar.ontop.button_focus
	config.titlebar_ontop_button_focus_active              = resources.titlebar.ontop.button_focus_active
	config.titlebar_ontop_button_focus_active_hover        = resources.titlebar.ontop.button_focus_active_hover
	config.titlebar_ontop_button_focus_active_press        = resources.titlebar.ontop.button_focus_active_press
	config.titlebar_ontop_button_focus_inactive            = resources.titlebar.ontop.button_focus_inactive
	config.titlebar_ontop_button_focus_inactive_hover      = resources.titlebar.ontop.button_focus_inactive_hover
	config.titlebar_ontop_button_focus_inactive_press      = resources.titlebar.ontop.button_focus_inactive_press
	config.titlebar_ontop_button_normal                    = resources.titlebar.ontop.button_normal
	config.titlebar_ontop_button_normal_active             = resources.titlebar.ontop.button_normal_active
	config.titlebar_ontop_button_normal_active_hover       = resources.titlebar.ontop.button_normal_active_hover
	config.titlebar_ontop_button_normal_active_press       = resources.titlebar.ontop.button_normal_active_press
	config.titlebar_ontop_button_normal_inactive           = resources.titlebar.ontop.button_normal_inactive
	config.titlebar_ontop_button_normal_inactive_hover     = resources.titlebar.ontop.button_normal_inactive_hover
	config.titlebar_ontop_button_normal_inactive_press     = resources.titlebar.ontop.button_normal_inactive_press


	-- [[ STICKY ]]--
	config.titlebar_sticky_button_normal                   = resources.titlebar.sticky.button_normal
	config.titlebar_sticky_button_focus                    = resources.titlebar.sticky.button_focus
	config.titlebar_sticky_button_normal_active            = resources.titlebar.sticky.button_normal_active
	config.titlebar_sticky_button_normal_active_hover      = resources.titlebar.sticky.button_normal_active_hover
	config.titlebar_sticky_button_normal_active_press      = resources.titlebar.sticky.button_normal_active_press
	config.titlebar_sticky_button_focus_active             = resources.titlebar.sticky.button_focus_active
	config.titlebar_sticky_button_focus_active_hover       = resources.titlebar.sticky.button_focus_active_hover
	config.titlebar_sticky_button_focus_active_press       = resources.titlebar.sticky.button_focus_active_press
	config.titlebar_sticky_button_normal_inactive          = resources.titlebar.sticky.button_normal_inactive
	config.titlebar_sticky_button_normal_inactive_hover    = resources.titlebar.sticky.button_normal_inactive_hover
	config.titlebar_sticky_button_normal_inactive_press    = resources.titlebar.sticky.button_normal_inactive_press
	config.titlebar_sticky_button_focus_inactive           = resources.titlebar.sticky.button_focus_inactive
	config.titlebar_sticky_button_focus_inactive_hover     = resources.titlebar.sticky.button_focus_inactive_hover
	config.titlebar_sticky_button_focus_inactive_press     = resources.titlebar.sticky.button_focus_inactive_press
end

return titlebar