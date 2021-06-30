local awful           = require("lib.awful")
local wibox           = require("lib.wibox")
local beautiful       = require("lib.beautiful")

local signals         = require("device.signals")
local config          = require("config")

local height          = 20
local width           = 20

local quitmenu_widget = {}

local function add(markup, image, command, fixed)
    local colorShow  = beautiful.colors.wibar[1]
    local colorHide  = beautiful.colors.wibar[3]
    local colorClick = beautiful.colors.wibar[9]

    local fixed      = fixed or wibox.layout.fixed.horizontal
    local command    = command or "nil"

    local textbox    = wibox.widget {
        {
            widget        = wibox.widget.textbox,
            markup        = markup,

            align         = "left",
            valign        = "center",

            font          = config.font,
            forced_height = height,
            forced_width  = 120,
        },
        bg     = colorHide,
        widget = wibox.container.background,
    }

    local imagebox   = wibox.widget {
        {
            widget        = wibox.widget.imagebox,
            image         = image,
            resize        = true,

            align         = "center",
            valign        = "center",

            forced_height = height,
            forced_width  = width,
        },
        bg     = colorHide,
        widget = wibox.container.background
    }

    local item       = wibox.layout {
        imagebox,
        textbox,
        widget = fixed,
    }

    item:connect_signal(signals.button.release,
                        function()
                            textbox.bg  = colorClick
                            imagebox.bg = colorClick
                            awful.util.spawn(command)
                            quitmenu_widget.show()
                        end)
    item:connect_signal(signals.mouse.enter,
                        function()
                            -- show
                            textbox.bg  = colorShow
                            imagebox.bg = colorShow
                        end)
    item:connect_signal(signals.mouse.leave,
                        function()
                            -- hide
                            textbox.bg  = colorHide
                            imagebox.bg = colorHide
                        end)

    return item
end

local buttons = {
    --system_config_samba      = add("Config samba", theme.quitmenu.system_config_samba),
    --system_error             = add("Error", theme.quitmenu.system_error),
    --system_file_manager      = add("File manager", theme.quitmenu.system_file_manager),
    system_help        = add("Help", "theme.quitmenu.system_help"),
    system_lock_screen = add("Lock screen", "theme.quitmenu.system_lock_screen"),
    system_log_out     = add("Logout", "theme.quitmenu.system_log_out"),
    system_reboot      = add("Reboot", "theme.quitmenu.system_reboot"),
    system_shutdown    = add("Shutdown", "theme.quitmenu.system_shutdown"),
    --system_software_update   = add("Software update", theme.quitmenu.system_software_update),
    system_suspend     = add("Suspend", "theme.quitmenu.system_suspend"),
    --system_suspend_hibernate = add("Hibernate", theme.quitmenu.system_suspend_hibernate),
    --system_switch_user       = add("Switch user", theme.quitmenu.system_switch_user),
    --system_users             = add("Users", theme.quitmenu.system_users),
}

local function worker()
    local s        = awful.screen.focused()
    local m_coords = {
        x = s.geometry.x + s.workarea.width / 2 - 100,
        y = s.geometry.y + s.workarea.height / 2 - 120
    }

    local menu     = wibox.widget {
        buttons.system_help,
        buttons.system_log_out,
        buttons.system_reboot,
        buttons.system_shutdown,
        buttons.system_suspend,
        buttons.system_lock_screen,
        layout = wibox.layout.fixed.vertical,
    }

    local popup    = awful.popup {
        ontop        = true,
        widget       = menu,
        -- обводка
        border_color = "#ff0000",
        border_width = "#00ffff",

        -- color background
        bg           = "#428bca",
        -- color text
        fg           = "#ffffff",

        placement    = awful.placement.top_left,
        -- делает закругления
        -- shape = gears.shape.rounded_rect,
        visible      = false,
    }

    function quitmenu_widget.show()
        popup.visible = not popup.visible
        awful.placement.top_right(popup,
                                  {
                                      margins = {
                                          top = 30,
                                      },
                                      parent  = awful.screen.focused()
                                  }
        )
    end

    return quitmenu_widget
end

return setmetatable(quitmenu_widget, { __call = function(_, ...)
    return worker(...)
end })
