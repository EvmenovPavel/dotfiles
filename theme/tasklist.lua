local gears    = require("lib.gears")
local config   = require("config")

local tasklist = {}

local shape    = {
    function(cr, width, height)
        gears.shape.transform(gears.shape.rounded_rect):translate(0, height - 1)(cr, width, 1, 0)
    end,

    function(cr, width, height)
        local top    = 0
        local left   = 0
        local radial = 5

        gears.shape.transform(gears.shape.rounded_rect):translate(left, top)(cr, width, height, radial)
    end
}

function tasklist:init(theme)
    -- шрифт + размер
    theme.tasklist_font              = config.font
    --theme.tasklist_font_focus        = theme.tasklist_font
    --theme.tasklist_font_minimized    = theme.tasklist_font
    --theme.tasklist_font_urgent       = theme.tasklist_font

    theme.tasklist_align             = config.position.left
    --Disable the tasklist client icons.
    theme.tasklist_disable_icon      = false
    -- скрывает текст
    theme.tasklist_disable_task_name = false


    -- цвет текста когда апп не свернуто (акт)
    --theme.tasklist_fg_focus                     = theme.colors.tasklist.focus[1]
    -- цвет бекграунд
    --theme.tasklist_bg_focus                     = theme.colors.tasklist.focus[2]
    --theme.tasklist_shape_border_color_focus     = theme.colors.tasklist.focus[3]
    --theme.tasklist_shape_border_width_focus     = 1
    theme.tasklist_shape_focus                  = shape[1]


    -- цвет текста когда апп не свернуто (но не акт)
    --theme.tasklist_fg_normal                    = theme.colors.tasklist.normal[1]
    -- цвет бекграунда
    --theme.tasklist_bg_normal                    = theme.colors.tasklist.normal[2]
    --theme.tasklist_shape_border_color           = theme.colors.tasklist.normal[3]
    --theme.tasklist_shape_border_width           = 1
    theme.tasklist_shape                        = shape[1]


    -- цвет теста при минимизе апп
    --theme.tasklist_fg_minimize                  = theme.colors.tasklist.minimize[1]
    -- цвет бекграунда
    --theme.tasklist_bg_minimize                  = theme.colors.tasklist.minimize[2]
    --theme.tasklist_shape_border_color_minimized = theme.colors.tasklist.minimize[3]
    --theme.tasklist_shape_border_width_minimized = 1
    theme.tasklist_shape_minimized              = shape[1]

    --theme.tasklist_fg_urgent                    = theme.colors.tasklist.urgent[1]
    -- цвет бекграунда
    --theme.tasklist_bg_urgent                    = theme.colors.tasklist.urgent[2]
    --theme.tasklist_shape_border_color_urgent    = theme.colors.tasklist.urgent[3]
    --theme.tasklist_shape_border_width_urgent    = 40
    theme.tasklist_shape_urgent                 = shape[1]


    -- Tasklist
    theme.tasklist_font              = theme.font

    theme.tasklist_bg_normal         = theme.bg_normal
    theme.tasklist_bg_focus          = theme.bg_focus
    theme.tasklist_bg_urgent         = theme.bg_urgent

    theme.tasklist_fg_focus          = theme.fg_focus
    theme.tasklist_fg_urgent         = theme.fg_urgent
    theme.tasklist_fg_normal         = theme.fg_normal




    -- уменьшает иконку
    theme.tasklist_margins           = 3
    -- размер (ширина) апп (икон + текст)
    theme.tasklist_forced_width      = 120
    -- отступ слева
    theme.tasklist_left              = 3
    -- отступ справа
    theme.tasklist_right             = 3
    -- отступ сверху
    theme.tasklist_top               = 1
    -- отступ снизу
    theme.tasklist_bottom            = 1
    -- отступ между апп -> (икон+текст) [отступ] (икон+текст)
    theme.tasklist_spacing           = 4
end

return setmetatable(tasklist, { __call = function(_, ...)
    return tasklist:init(...)
end })