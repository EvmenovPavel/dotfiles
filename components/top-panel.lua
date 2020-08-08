local awful     = require("lib.awful")
local beautiful = require("lib.beautiful")
local wibox     = require("lib.wibox")
local gears     = require("lib.gears")
local dpi       = beautiful.xresources.apply_dpi

-- import widgets
local tasklist  = require("widgets.tasklist")
local taglist   = require("widgets.taglist")

-- define module table
local top_panel = {}

function left_widget(s)
    return {
        taglist.create(s),
        layout = wibox.layout.fixed.horizontal
    }
end

function middle_widget(s)
    return {
        tasklist.create(s),
        layout = wibox.layout.fixed.horizontal
    }
end

function right_widget(s)
    return {
        wibox.layout.margin(require("widgets.systray"), 3, 3, 3, 3),

        awful.widget.keyboardlayout(),

        require("widgets.cpu-widget"),
        require("widgets.calendar"),
        --require("widgets.bluetooth"),
        --require("widgets.wifi"),
        --require("widgets.battery"),
        --require("widgets.layout-box"),

        --require("widgets.reboot"),
        --require("widgets.checkbox"),
        require("widgets.notifications"),

        layout = wibox.layout.fixed.horizontal
    }
end

top_panel.create = function(s)
    local panel_shape           = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, false, true, true, false, 0)
    end
    local maximized_panel_shape = function(cr, width, height)
        gears.shape.rectangle(cr, width, height)
    end

    local panel                 = awful.wibar({
                                                  screen   = s,
                                                  position = "top",
                                                  --workarea = true,
                                                  width    = s.geometry.width,
                                                  height   = 30,
                                                  ontop    = true,

                                                  shape    = maximized_panel_shape
                                              })

    panel:setup {
        left_widget(s),
        middle_widget(s),
        right_widget(s),
        layout = wibox.layout.align.horizontal,
    }

    -- hide panel when client is fullscreen
    client.connect_signal('property::fullscreen',
                          function(c)
                              --panel.visible = not c.fullscreen
                          end
    )
end

return top_panel
