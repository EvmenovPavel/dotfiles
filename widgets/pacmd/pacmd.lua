local beautiful = require("beautiful")
local wibox     = require("wibox")
local watch     = require("awful.widget.watch")

local pacmd     = {}

function pacmd:init(args)
    local args          = args or {}

    local width         = args.width or 50
    local step_width    = args.step_width or 2
    local step_spacing  = args.step_spacing or 1
    local color         = args.color or beautiful.fg_normal

    local pacmd_widget  = wibox.widget({
                                           max_value        = 100,
                                           background_color = "#00000000",
                                           forced_width     = width,
                                           step_width       = step_width,
                                           step_spacing     = step_spacing,
                                           widget           = wibox.widget.graph,
                                           color            = "linear:0,0:0,20:0,#FF0000:0.3,#FFFF00:0.6," .. color
                                       })

    local text_widget   = wibox.widget({
                                           font   = beautiful.font,

                                           widget = wibox.widget.textbox,
                                           markup = "ram",

                                           align  = "left",
                                           valign = "center",

                                           widget = wibox.widget.textbox,
                                       })

    local memory_widget = wibox.container.margin(wibox.container.mirror(pacmd_widget, { horizontal = true }), 2, 2, 2, 2)

    watch([[bash -c "pacmd list-modules | grep latency_msec=5"]], 1,
          function(widget, stdout)
              capi.log:message(stdout)

              --local _mem = { buf = {}, swp = {} }

              --pacmd unload-module module-loopback

              --pacmd list-modules | grep latency_msec=5

              --pacmd load-module module-loopback latency_msec=5


              --widget:add_value()
          end,
          pacmd_widget
    )

    local memory_text = wibox.container.margin(wibox.container.mirror(text_widget, { horizontal = false }), 2, 2, 2, 2)

    local widget      = wibox.widget({
                                         memory_text,
                                         memory_widget,
                                         layout = wibox.layout.align.horizontal
                                     })

    return widget
end

return setmetatable(pacmd, {
    __call = pacmd.init
})