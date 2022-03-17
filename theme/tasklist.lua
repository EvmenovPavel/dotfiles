local gears    = require("gears")

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
    theme.tasklist_disable_icon      = false
    theme.tasklist_disable_task_name = false

    -- Tasklist
    theme.tasklist_font              = theme.font

    theme.tasklist_bg_normal         = theme.bg_normal
    theme.tasklist_bg_focus          = theme.bg_focus
    theme.tasklist_bg_urgent         = theme.bg_urgent

    theme.tasklist_fg_focus          = theme.fg_focus
    theme.tasklist_fg_urgent         = theme.fg_urgent
    theme.tasklist_fg_normal         = theme.fg_normal


    -- уменьшает иконку
    theme.tasklist_margins           = 2
    theme.tasklist_widget            = 4
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
    theme.tasklist_spacing           = 1
end

return setmetatable(tasklist, { __call = function(_, ...)
    return tasklist:init(...)
end })