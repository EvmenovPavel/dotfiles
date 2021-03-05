local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local mouse     = capi.wmapi.event.mouse

local cpu       = {}

local cpu_rows  = {
    spacing = 4,
    layout  = wibox.layout.fixed.vertical,
}

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

function cpu:init()
    local wTextbox = capi.wmapi:textbox({ forced_width = 75 })
    local wGraph   = capi.wmapi:graph()

    local popup    = capi.wmapi:popup({})

    local func     = function()
        if popup.visible then
            popup.visible = not popup.visible
        else
            popup:move_next_to(capi.mouse.current_widget_geometry)
        end
    end

    local cpus = {}
    local bash = [[bash -c "cat /proc/stat | grep "^cpu." ; ps -eo "%p|%c|%C|" -o "%mem" -o "|%a" --sort=-%cpu | head -11 | tail -n +2"]]
    awful.widget.watch(bash, 3,
                       function(widget, stdout)
                           local i = 1
                           for line in stdout:gmatch("[^\r\n]+") do
                               if starts_with(line, "cpu") then

                                   if cpus[i] == nil then
                                       cpus[i] = {}
                                   end

                                   local name, user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice = line:match("(%w+)%s+(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)")

                                   local total                                                                          = user + nice + system + idle + iowait + irq + softirq + steal

                                   local diff_idle                                                                      = idle - tonumber(cpus[i]["idle_prev"] == nil and 0 or cpus[i]["idle_prev"])
                                   local diff_total                                                                     = total - tonumber(cpus[i]["total_prev"] == nil and 0 or cpus[i]["total_prev"])
                                   local diff_usage                                                                     = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10

                                   cpus[i]["total_prev"]                                                                = total
                                   cpus[i]["idle_prev"]                                                                 = idle

                                   if i == 1 then
                                       wTextbox.markup = "CPU [" .. math.floor(diff_usage) .. "%" .. "]"
                                       widget:add_value(diff_usage)
                                   end

                                   local row = wibox.widget {
                                       capi.wmapi:textbox({ markup = name }),
                                       capi.wmapi:textbox({ markup = math.floor(diff_usage) .. "%" }),
                                       {
                                           max_value        = 100,
                                           value            = diff_usage,
                                           forced_height    = 20,
                                           forced_width     = 150,
                                           paddings         = 1,
                                           margins          = 4,
                                           border_width     = 1,
                                           border_color     = beautiful.bg_focus,
                                           background_color = beautiful.bg_normal,
                                           bar_border_width = 1,
                                           bar_border_color = beautiful.bg_focus,
                                           color            = "linear:150,0:0,0:0,#D08770:0.3,#BF616A:0.6," .. beautiful.fg_normal,
                                           widget           = wibox.widget.progressbar,

                                       },
                                       layout = wibox.layout.ratio.horizontal
                                   }
                                   row:ajust_ratio(2, 0.15, 0.15, 0.7)
                                   cpu_rows[i] = row
                                   i           = i + 1
                               end
                           end
                           popup:setup {
                               {
                                   cpu_rows,
                                   {
                                       orientation   = "horizontal",
                                       forced_height = 15,
                                       color         = beautiful.bg_focus,
                                       widget        = wibox.widget.separator
                                   },
                                   layout = wibox.layout.fixed.vertical,
                               },
                               margins = 8,
                               widget  = wibox.container.margin
                           }
                       end,
                       wGraph
    )

    local wText  = wibox.container.margin(wibox.container.mirror(wTextbox, { horizontal = false }), 2, 2, 2, 2)
    local wCpu   = wibox.container.margin(wibox.container.mirror(wGraph, { horizontal = true }), 0, 0, 0, 2)

    --local widget = capi.wmapi:layout_align_horizontal({memory_text, cpu_widget})

    -- TODO
    local widget = wibox.widget({
                                    wText,
                                    --wCpu,
                                    layout = wibox.layout.align.horizontal
                                })

    capi.wmapi:buttons({ widget = widget, event = mouse.button_click_left, func = func })

    return widget
end

return setmetatable(cpu, {
    __call = cpu.init
})

