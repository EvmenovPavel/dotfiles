local resources = require("resources")

local taglist   = {}

local function init(theme)
    theme.taglist_disable_icon = false

    theme.taglist_count        = 10

    --отспут между item
    theme.taglist_spacing      = 0

    -- Taglist
    theme.taglist_bg_empty     = theme.bg_normal
    theme.taglist_bg_occupied  = "#ffffff1a"
    theme.taglist_bg_urgent    = "#e91e6399"
    theme.taglist_bg_focus     = theme.bg_focus

    theme.taglist_icons        = resources.taglist
end

return setmetatable(taglist, { __call = function(_, ...)
    return init(...)
end })