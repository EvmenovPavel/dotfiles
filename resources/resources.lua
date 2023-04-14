resources                   = {}

resources.path              = dir.awesomewm .. "/resources/icons"
resources.wallpaper         = dir.awesomewm .. "/resources/wallpapers"
resources.awesome           = resources.path .. "/awesome.png"

resources.menu_submenu_icon = resources.path .. "/submenu.png"
resources.warning           = resources.path .. "/warning.png"

resources.battery           = {
	caution_charging   = resources.path .. "/battery/battery-caution-charging-symbolic.svg",
	caution            = resources.path .. "/battery/battery-caution-symbolic.svg",
	empty_charging     = resources.path .. "/battery/battery-empty-charging-symbolic.svg",
	empty              = resources.path .. "/battery/battery-empty-symbolic.svg",
	full_charged       = resources.path .. "/battery/battery-full-charged-symbolic.svg",
	full_charging      = resources.path .. "/battery/battery-full-charging-symbolic.svg",
	full               = resources.path .. "/battery/battery-full-symbolic.svg",
	good_charging      = resources.path .. "/battery/battery-good-charging-symbolic.svg",
	good               = resources.path .. "/battery/battery-good-symbolic.svg",

	level_0            = resources.path .. "/battery/battery-level-0-symbolic.svg",
	level_10           = resources.path .. "/battery/battery-level-10-symbolic.svg",
	level_20           = resources.path .. "/battery/battery-level-20-symbolic.svg",
	level_30           = resources.path .. "/battery/battery-level-30-symbolic.svg",
	level_40           = resources.path .. "/battery/battery-level-40-symbolic.svg",
	level_50           = resources.path .. "/battery/battery-level-50-symbolic.svg",
	level_60           = resources.path .. "/battery/battery-level-60-symbolic.svg",
	level_70           = resources.path .. "/battery/battery-level-70-symbolic.svg",
	level_80           = resources.path .. "/battery/battery-level-80-symbolic.svg",
	level_90           = resources.path .. "/battery/battery-level-90-symbolic.svg",
	level_100          = resources.path .. "/battery/battery-level-100-symbolic.svg",

	level_0_charging   = resources.path .. "/battery/battery-level-0-charging-symbolic.svg",
	level_10_charging  = resources.path .. "/battery/battery-level-10-charging-symbolic.svg",
	level_20_charging  = resources.path .. "/battery/battery-level-20-charging-symbolic.svg",
	level_30_charging  = resources.path .. "/battery/battery-level-30-charging-symbolic.svg",
	level_40_charging  = resources.path .. "/battery/battery-level-40-charging-symbolic.svg",
	level_50_charging  = resources.path .. "/battery/battery-level-50-charging-symbolic.svg",
	level_60_charging  = resources.path .. "/battery/battery-level-60-charging-symbolic.svg",
	level_70_charging  = resources.path .. "/battery/battery-level-70-charging-symbolic.svg",
	level_80_charging  = resources.path .. "/battery/battery-level-80-charging-symbolic.svg",
	level_90_charging  = resources.path .. "/battery/battery-level-90-charging-symbolic.svg",
	level_100_charging = resources.path .. "/battery/battery-level-100-charging-symbolic.svg",
	level_100_charged  = resources.path .. "/battery/battery-level-100-charged-symbolic.svg",

	low_charging       = resources.path .. "/battery/battery-low-charging-symbolic.svg",
	low                = resources.path .. "/battery/battery-low-symbolic.svg",

	missing            = resources.path .. "/battery/battery-missing-symbolic.svg",
}

resources.pngegg            = resources.path .. "/pngegg.png"

resources.checkbox          = {
	checkbox = resources.path .. "/widgets/checkbox/checkbox.svg"
}

resources.taglist           = {
	resources.path .. "/taglist/firefox.png",
	resources.path .. "/taglist/folder.png",
	resources.path .. "/taglist/mail.png",
	resources.path .. "/taglist/messager.png",
	resources.path .. "/taglist/notepad.png",
	resources.path .. "/taglist/player.png",
	resources.path .. "/taglist/spotify.png",
	resources.path .. "/taglist/star.png",
	resources.path .. "/taglist/terminal.png",
	resources.path .. "/taglist/videogame.png"
}

resources.layout            = {
	tile       = resources.path .. "/layouts/tile.png",
	tileleft   = resources.path .. "/layouts/tileleft.png",
	tilebottom = resources.path .. "/layouts/tilebottom.png",
	tiletop    = resources.path .. "/layouts/tiletop.png",
	fairv      = resources.path .. "/layouts/fairv.png",
	fairh      = resources.path .. "/layouts/fairh.png",
	spiral     = resources.path .. "/layouts/spiral.png",
	centerwork = resources.path .. "/layouts/centerwork.png",
	dwindle    = resources.path .. "/layouts/dwindle.png",
	max        = resources.path .. "/layouts/max.png",
	fullscreen = resources.path .. "/layouts/fullscreen.png",
	magnifier  = resources.path .. "/layouts/magnifier.png",
	floating   = resources.path .. "/layouts/floating.png",
}

-- Widget icons
resources.widgets           = {
	memory   = resources.path .. "/widgets/memory/memory.svg",

	coretemp = {
		veryLow      = resources.path .. "/widgets/coretemp/Very Low.svg",
		belowAverage = resources.path .. "/widgets/coretemp/Below Average.svg",
		average      = resources.path .. "/widgets/coretemp/Average.svg",
		aboveAverage = resources.path .. "/widgets/coretemp/Above Average.svg",
		veryHigh     = resources.path .. "/widgets/coretemp/Very High.svg",
	},

	calendar = resources.path .. "/calendar/calendar.svg",

	cpu      = resources.path .. "/cpu/cpu.svg",

	user     = resources.path .. "/user/user.svg",

	power    = resources.path .. "/power/power-off.svg",

	search   = resources.path .. "/search/search.svg",

	volume   = {
		on  = resources.path .. "/volume/volume_on.png",
		off = resources.path .. "/volume/volume_off.png"
	},

	--resources.widget.ac                                       = resources.path .. "/widget/ac.png"
	--resources.widget.battery                                  = resources.path .. "/widget/battery.png"
	--resources.widget.user                                     = resources.path .. "/widget/user.png"
	--resources.widget.cpu                                      = resources.path .. "/widget/cpu.png"
	--resources.widget.net                                      = resources.path .. "/widget/net.png"
	--resources.widget.hdd                                      = resources.path .. "/widget/ssd.png"
	--resources.widget.vol                                      = resources.path .. "/widget/spkr.png"
	--resources.widget.mail                                     = resources.path .. "/widget/mail.png"
	--resources.widget.task                                     = resources.path .. "/widget/task.png"
	--resources.widget.scissors                                 = resources.path .. "/widget/scissors.png"
}

-- Quit menu
--resources.quitmenu                                        = {}
--resources.quitmenu.system_config_samba                    = resources.path .. "/quitmenu/config-samba.png"
--resources.quitmenu.system_error                           = resources.path .. "/quitmenu/error.png"
--resources.quitmenu.system_file_manager                    = resources.path .. "/quitmenu/file-manager.png"
--resources.quitmenu.system_help                            = resources.path .. "/quitmenu/help.png"
--resources.quitmenu.system_lock_screen                     = resources.path .. "/quitmenu/lock-screen.png"
--resources.quitmenu.system_log_out                         = resources.path .. "/quitmenu/log-out.png"
--resources.quitmenu.system_reboot                          = resources.path .. "/quitmenu/reboot.png"
--resources.quitmenu.system_shutdown                        = resources.path .. "/quitmenu/shutdown.png"
--resources.quitmenu.system_software_update                 = resources.path .. "/quitmenu/software-update.png"
--resources.quitmenu.system_suspend                         = resources.path .. "/quitmenu/suspend.png"
--resources.quitmenu.system_suspend_hibernate               = resources.path .. "/quitmenu/suspend-hibernate.png"
--resources.quitmenu.system_switch_user                     = resources.path .. "/quitmenu/switch-user.png"
--resources.quitmenu.system_users                           = resources.path .. "/quitmenu/users.png"

resources.titlebar          = {
	-- hover - срабатывает при навидении
	-- press - срабатывает при удержании

	--[[
	bgimage

	--The titlebar background image image.
	resources.titlebar_.bgimage_normal
	--The titlebar background image image.
	resources.titlebar_.bgimage
	--The focused titlebar background image image.
	resources.titlebar_.bgimage_focus
	]]--

	menu      = {
		--[[act app]]--
		button_focus        = resources.path .. "/titlebar/menu/focus.svg",
		button_focus_hover  = resources.path .. "/titlebar/menu/focus_hover.svg",
		button_focus_press  = resources.path .. "/titlebar/menu/focus_press.svg",
		--[[no act app]]--
		button_normal       = resources.path .. "/titlebar/menu/normal.svg",
		button_normal_hover = resources.path .. "/titlebar/menu/normal_hover.svg",
		button_normal_press = resources.path .. "/titlebar/menu/normal_press.svg",
	},


	--floating
	floating  = {
		--[[act app]]--
		button_focus_active          = resources.path .. "/titlebar/floating/focus_active.png",
		button_focus_active_hover    = resources.path .. "/titlebar/floating/focus_active_hover.png",
		button_focus_active_press    = resources.path .. "/titlebar/floating/focus_active_press.png",
		button_focus_inactive        = resources.path .. "/titlebar/floating/focus_inactive.png",
		button_focus_inactive_hover  = resources.path .. "/titlebar/floating/focus_inactive_hover.png",
		button_focus_inactive_press  = resources.path .. "/titlebar/floating/focus_inactive_press.png",
		--[[no act app]]--
		button_normal_active         = resources.path .. "/titlebar/floating/normal_active.png",
		button_normal_active_hover   = resources.path .. "/titlebar/floating/normal_active_hover.png",
		button_normal_active_press   = resources.path .. "/titlebar/floating/normal_active_press.png",
		button_normal_inactive       = resources.path .. "/titlebar/floating/normal_inactive.png",
		button_normal_inactive_hover = resources.path .. "/titlebar/floating/normal_inactive_hover.png",
		button_normal_inactive_press = resources.path .. "/titlebar/floating/normal_inactive_press.png",
	},


	--maximized
	maximized = {
		--[[act app]]--
		button_focus_active          = resources.path .. "/titlebar/maximized/focus_active.svg",
		button_focus_active_hover    = resources.path .. "/titlebar/maximized/focus_active_hover.svg",
		button_focus_active_press    = resources.path .. "/titlebar/maximized/focus_active_press.svg",
		button_focus_inactive        = resources.path .. "/titlebar/maximized/focus.svg",
		button_focus_inactive_hover  = resources.path .. "/titlebar/maximized/focus_hover.svg",
		button_focus_inactive_press  = resources.path .. "/titlebar/maximized/focus_press.svg",
		--[[no act app]]--
		button_normal_active         = resources.path .. "/titlebar/maximized/normal_active.svg",
		button_normal_active_hover   = resources.path .. "/titlebar/maximized/normal_active_hover.svg",
		button_normal_active_press   = resources.path .. "/titlebar/maximized/normal_active_press.svg",
		button_normal_inactive       = resources.path .. "/titlebar/maximized/normal_inactive.svg",
		button_normal_inactive_hover = resources.path .. "/titlebar/maximized/normal_inactive_hover.svg",
		button_normal_inactive_press = resources.path .. "/titlebar/maximized/normal_inactive_press.svg",
	},


	--minimize
	minimize  = {
		--[[act app]]--
		button_focus        = resources.path .. "/titlebar/minimize/focus.svg",
		button_focus_hover  = resources.path .. "/titlebar/minimize/focus_hover.svg",
		button_focus_press  = resources.path .. "/titlebar/minimize/focus_press.svg",
		--[[no act app]]--
		button_normal       = resources.path .. "/titlebar/minimize/normal.svg",
		button_normal_hover = resources.path .. "/titlebar/minimize/normal_hover.svg",
		button_normal_press = resources.path .. "/titlebar/minimize/normal_press.svg",
	},


	--close
	close     = {
		--[[act app]]--
		button_focus        = resources.path .. "/titlebar/close/focus.svg",
		button_focus_hover  = resources.path .. "/titlebar/close/focus_hover.svg",
		button_focus_press  = resources.path .. "/titlebar/close/focus_press.svg",
		--[[no act app]]--
		button_normal       = resources.path .. "/titlebar/close/normal.svg",
		button_normal_hover = resources.path .. "/titlebar/close/normal_hover.svg",
		button_normal_press = resources.path .. "/titlebar/close/normal_press.svg",
	},


	--ontop
	ontop     = {
		--[[act app]]--
		button_focus                 = resources.path .. "/titlebar/ontop/button_focus.png",
		button_focus_active          = resources.path .. "/titlebar/ontop/button_focus_active.png",
		button_focus_active_hover    = resources.path .. "/titlebar/ontop/button_focus_active_hover.png",
		button_focus_active_press    = resources.path .. "/titlebar/ontop/button_focus_active_press.png",
		button_focus_inactive        = resources.path .. "/titlebar/ontop/button_focus_inactive.png",
		button_focus_inactive_hover  = resources.path .. "/titlebar/ontop/button_focus_inactive_hover.png",
		button_focus_inactive_press  = resources.path .. "/titlebar/ontop/button_focus_inactive_press.png",
		--[[no act app]]--
		button_normal                = resources.path .. "/titlebar/ontop/button_normal.png",
		button_normal_active         = resources.path .. "/titlebar/ontop/button_normal_active.png",
		button_normal_active_hover   = resources.path .. "/titlebar/ontop/button_normal_active_hover.png",
		button_normal_active_press   = resources.path .. "/titlebar/ontop/button_normal_active_press.png",
		button_normal_inactive       = resources.path .. "/titlebar/ontop/button_normal_inactive.png",
		button_normal_inactive_hover = resources.path .. "/titlebar/ontop/button_normal_inactive_hover.png",
		button_normal_inactive_press = resources.path .. "/titlebar/ontop/button_normal_inactive_press.png",
	},


	--sticky
	sticky    = {
		--[[act app]]--
		button_focus_active          = resources.path .. "/titlebar/sticky/focus_active.png",
		button_focus_active_hover    = resources.path .. "/titlebar/sticky/focus_active_hover.png",
		button_focus_active_press    = resources.path .. "/titlebar/sticky/focus_active_press.png",
		button_focus_inactive        = resources.path .. "/titlebar/sticky/focus_inactive.png",
		button_focus_inactive_hover  = resources.path .. "/titlebar/sticky/focus_inactive_hover.png",
		button_focus_inactive_press  = resources.path .. "/titlebar/sticky/focus_inactive_press.png",
		--[[no act app]]--
		button_normal_active         = resources.path .. "/titlebar/sticky/normal_active.png",
		button_normal_active_hover   = resources.path .. "/titlebar/sticky/normal_active_hover.png",
		button_normal_active_press   = resources.path .. "/titlebar/sticky/normal_active_press.png",
		button_normal_inactive       = resources.path .. "/titlebar/sticky/normal_inactive.png",
		button_normal_inactive_hover = resources.path .. "/titlebar/sticky/normal_inactive_hover.png",
		button_normal_inactive_press = resources.path .. "/titlebar/sticky/normal_inactive_press.png",
	},
}

resources.wallpapers        = {
	png_1     = resources.wallpaper .. "/1.png",
	ruby_rose = resources.wallpaper .. "/2.png",
	spider    = resources.wallpaper .. "/spider-man-into.jpeg",
	wallpaper = resources.wallpaper .. "/wallpaper.png",
}

resources.calendar          = {
	next = resources.path .. "/go-next.png",
	prev = resources.path .. "/go-previous.png",
}
