local gears          = require("gears")
local object         = require("gears.object")
local cache          = require("gears.cache")
local matrix         = require("gears.matrix")
local protected_call = require("gears.protected_call")
local gtable         = require("gears.table")
local awful          = require("awful")
local wibox          = require("wibox")
local beautiful      = require("beautiful")

local setmetatable   = setmetatable
local pairs          = pairs
local type           = type
local table          = table

local base           = {}

function base:init(shape)
    local ret          = {}

    ret._private       = {}
    ret._private.shape = shape or function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 10)
    end

    ret.widget         = wibox.widget({
                                          --{
                                          --    widget = wibox.container.background(),
                                          --},

                                          margins = 4,
                                          widget  = wibox.container.margin,

                                          shape   = ret._private.shape
                                      })

    function ret:set_shape(shape)
        ret.widget:set_shape(shape)
    end

    function ret:set_widget(widget)
        ret.widget:set_widget(widget)
    end

    function ret:get()
        return ret.widget
    end

    return ret
end

return base