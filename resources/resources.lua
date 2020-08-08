local config                = require("config")

local resources             = {}

resources.path              = config.awesome .. "/resources/icons"
resources.awesome           = resources.path .. "/awesome.png"

resources.menu_submenu_icon = resources.path .. "/submenu.png"
resources.warning           = resources.path .. "/warning.png"

resources.layout            = {
    -- Layout icons
    --resources.layout                                          = {}
    --resources.layout.tile                                     = resources.path .. "/layouts/tile.png"
    --resources.layout.tileleft                                 = resources.path .. "/layouts/tileleft.png"
    --resources.layout.tilebottom                               = resources.path .. "/layouts/tilebottom.png"
    --resources.layout.tiletop                                  = resources.path .. "/layouts/tiletop.png"
    --resources.layout.fairv                                    = resources.path .. "/layouts/fairv.png"
    --resources.layout.fairh                                    = resources.path .. "/layouts/fairh.png"
    --resources.layout.spiral                                   = resources.path .. "/layouts/spiral.png"
    --resources.layout.centerwork                               = resources.path .. "/layouts/centerwork.png"
    --resources.layout.dwindle                                  = resources.path .. "/layouts/dwindle.png"
    --resources.layout.max                                      = resources.path .. "/layouts/max.png"
    --resources.layout.fullscreen                               = resources.path .. "/layouts/fullscreen.png"
    --resources.layout.magnifier                                = resources.path .. "/layouts/magnifier.png"
    --resources.layout.floating                                 = resources.path .. "/layouts/floating.png"
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

    calendar = resources.path .. "/widgets/calendar/calendar.svg",

    cpu      = resources.path .. "/widgets/cpu/cpu.svg",

    user     = resources.path .. "/widgets/user/user.svg",

    power    = resources.path .. "/widgets/power/power-off.svg",

    search   = resources.path .. "/widgets/search/search.svg",

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
        button_focus_active          = resources.path .. "/titlebar/ontop/focus_active.png",
        button_focus_active_hover    = resources.path .. "/titlebar/ontop/focus_active_hover.png",
        button_focus_active_press    = resources.path .. "/titlebar/ontop/focus_active_press.png",
        button_focus_inactive        = resources.path .. "/titlebar/ontop/focus_inactive.png",
        button_focus_inactive_hover  = resources.path .. "/titlebar/ontop/focus_inactive_hover.png",
        button_focus_inactive_press  = resources.path .. "/titlebar/ontop/focus_inactive_press.png",
        --[[no act app]]--
        button_normal_active         = resources.path .. "/titlebar/ontop/normal_active.png",
        button_normal_active_hover   = resources.path .. "/titlebar/ontop/normal_active_hover.png",
        button_normal_active_press   = resources.path .. "/titlebar/ontop/normal_active_press.png",
        button_normal_inactive       = resources.path .. "/titlebar/ontop/normal_inactive.png",
        button_normal_inactive_hover = resources.path .. "/titlebar/ontop/normal_inactive_hover.png",
        button_normal_inactive_press = resources.path .. "/titlebar/ontop/normal_inactive_press.png",
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
return resources