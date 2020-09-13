local awful   = require("lib.awful")
local wibox   = require("lib.wibox")
local gears   = require("lib.gears")
local widgets = require("widgets")

local wmapi   = require("lib.wmapi")
local config  = require("config")

local mywibar = {}

function w_left(s)
    return {
        widgets.taglist.create(s),
        layout = wibox.layout.fixed.horizontal
    }
end

function w_middle(s)
    return {
        widgets.tasklist:create(s),
        layout = wibox.layout.fixed.horizontal
    }
end

function w_right(s)
    if wmapi:display_primary(s) then
        return {
            widgets.systray,
            widgets.keyboard(),
            widgets.volume(s),
            widgets.calendar,
            widgets.reboot,
            layout = wibox.layout.fixed.horizontal
        }
    end

    return {
        layout = wibox.layout.fixed.horizontal
    }
end

local shape = {
    function(cr, width, height)
        gears.shape.rectangle(cr, width, height)

        --gears.shape.transform(gears.shape.rounded_rect):translate(0, -1)(cr, width, height, 0)
    end,

    function(cr, width, height)
        local top    = 0
        local left   = 0
        local radial = 5

        gears.shape.transform(gears.shape.rounded_rect):translate(left, top)(cr, width, height, radial)
    end
}

function mywibar:create(s)
    local panel_shape           = function(cr, width, height)
        --gears.shape.partially_rounded_rect(cr, width, height, false, true, true, false, 0)
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

                                                  shape        = shape[1], --maximized_panel_shape,

                                                  -- Цвет обводки.
                                                  --border_color = "#000000",
                                                  -- цвет бара
                                                  --bg           = "#00000055",
                                                  -- цвет текста
                                                  --fg           = "#00000055",

                                                  screen       = s,
                                              })

    s.mywibar:setup {
        w_left(s),
        w_middle(s),
        w_right(s),
        layout = wibox.layout.align.horizontal,
    }
end

return setmetatable(mywibar, {
    __call = mywibar.create,
})
