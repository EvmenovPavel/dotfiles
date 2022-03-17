local beautiful = require("beautiful")
local wibox     = require("wibox")

local graph     = {}

function graph:create(args)
    local ret       = {}
    local args      = args or {}

    local set_color = ({
        type  = "linear",
        from  = { 0, 0 },
        to    = { 10, 0 },
        stops = { { 0, "#FF5656" },
                  { 0.5, "#88A175" },
                  { 1, "#AECF96" } }
    })

    ret.widget      = wibox.widget({
                                       type             = "graph",
                                       widget           = wibox.widget.graph,

                                       max_value        = args.max_value or 100,

                                       background_color = args.background_color or "#00000000",

                                       forced_width     = args.forced_width or 50,

                                       step_width       = args.step_width or 2,
                                       step_spacing     = args.step_spacing or 1,

                                       color            = beautiful.fg_normal or set_color
                                       --"linear:0,1:#FFFF00,20:0,#FF0000:0.1,#FFFF00:0.4," .. beautiful.fg_normal
                                   })

    return ret
end

return graph