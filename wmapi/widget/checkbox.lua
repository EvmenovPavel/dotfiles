local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local checkbox  = {}

function checkbox:create()
    local ret  = {}

    ret.widget = wibox.widget({
                                  type               = "checkbox",

                                  --checked  = true,
                                  --color    = beautiful.bg_normal,
                                  --paddings = 2,
                                  --shape    = gears.shape.circle,

                                  color              = beautiful.bg_normal,
                                  bg                 = '#ff00ff',
                                  border_width       = 3,
                                  paddings           = 4,
                                  border_color       = '#0000ff',
                                  check_color        = '#ff0000',
                                  check_border_color = '#ffff00',
                                  check_border_width = 1,

                                  widget             = wibox.widget.checkbox,
                              })

    function ret:get()
        return self.widget
    end

    function ret:checked()
        self.widget.checked = not self.widget.checked
    end

    return ret
end

return checkbox
