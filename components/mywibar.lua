local awful   = require("lib.awful")
local wibox   = require("lib.wibox")
local gears   = require("lib.gears")
local widgets = require("widgets")

local wmapi   = require("lib.wmapi")
local config  = require("config")


-- define module table
local mywibar = {}

function left_widget(s)
    return {
        widgets.taglist.create(s),
        layout = wibox.layout.fixed.horizontal
    }
end

function middle_widget(s)
    return {
        widgets.tasklist.create(s),
        layout = wibox.layout.fixed.horizontal
    }
end

function right_widget(s)

    if wmapi:index(s) == 1 then
        return {
            widgets.systray,
            widgets.keyboard,
            widgets.volume(s),
            widgets.calendar,
            layout = wibox.layout.fixed.horizontal
        }
    end

    return {
        layout = wibox.layout.fixed.horizontal
    }
end

function mywibar:create(s)
    local panel_shape           = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, false, true, true, false, 0)
    end
    local maximized_panel_shape = function(cr, width, height)
        gears.shape.rectangle(cr, width, height)
    end

    s.mywibar                   = awful.wibar({
                                                  -- Делает поверх всего
                                                  ontop        = false,
                                                  --Если wibar нужно растянуть, чтобы заполнить экран.
                                                  stretch      = true,
                                                  --Положение Wibox.
                                                  position     = config.position.top,
                                                  -- Размер обводки
                                                  border_width = 0,
                                                  --Visibility.
                                                  visible      = true,
                                                  -- размер (высота) бара
                                                  height       = 27,
                                                  -- ширина бара (если stretch = true, то игнорирует)
                                                  width        = wmapi.screen_width - 30,

                                                  --shape        = maximized_panel_shape,

                                                  -- Цвет обводки.
                                                  --border_color = "#000000",
                                                  -- цвет бара
                                                  --bg           = "#00000055",
                                                  -- цвет текста
                                                  --fg           = "#00000055",

                                                  screen       = s,
                                              })

    s.mywibar:setup {
        left_widget(s),
        middle_widget(s),
        right_widget(s),
        layout = wibox.layout.align.horizontal,
    }
end

return setmetatable(mywibar, {
    __call = mywibar.create,
})