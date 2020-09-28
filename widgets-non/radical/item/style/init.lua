local holo    = require( "widgets.radical.item.style.holo")
local rounded = require( "widgets.radical.item.style.rounded")
local theme   = require("widgets.radical.theme")
local unpack  = unpack or table.unpack

-- Create a generic item_style
local function generic(_, args)
    args         = args or {}

    args.margins = args.margins or {
        TOP    = 0,
        BOTTOM = 0,
        RIGHT  = 0,
        LEFT   = 0
    }

    local module = {
        margins = args.margins
    }

    local function draw(item)
        item.widget:set_shape(args.shape or item.shape, unpack(args.shape_args or {}))
        item.widget:set_shape_border_width(item.border_width)
        theme.update_colors(item)
    end

    return setmetatable(module, { __call = function(_, ...)
        return draw(...)
    end })
end

return setmetatable({
                        basic          = require( "widgets.radical.item.style.basic"),
                        classic        = require( "widgets.radical.item.style.classic"),
                        rounded_shadow = rounded.shadow,
                        rounded        = rounded,
                        holo           = holo,
                        holo_top       = holo.top,
                        arrow_prefix   = require( "widgets.radical.item.style.arrow_prefix"),
                        arrow_single   = require( "widgets.radical.item.style.arrow_single"),
                        arrow_3d       = require( "widgets.radical.item.style.arrow_3d"),
                        slice_prefix   = require( "widgets.radical.item.style.slice_prefix"),
                        line_3d        = require( "widgets.radical.item.style.line_3d"),
                    }, { __call = generic })
