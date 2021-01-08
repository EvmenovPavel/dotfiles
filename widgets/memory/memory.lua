local beautiful = require("beautiful")
local wibox     = require("wibox")
local watch     = require("awful.widget.watch")

local resources = require("resources")

local memory    = {}

function memory:init(args)
    local args                    = args or {}

    local width                   = args.width or 50
    local step_width              = args.step_width or 2
    local step_spacing            = args.step_spacing or 1
    local color                   = args.color or beautiful.fg_normal

    local memorygraph_widget      = wibox.widget {
        max_value        = 100,
        background_color = "#00000000",
        forced_width     = width,
        step_width       = step_width,
        step_spacing     = step_spacing,
        widget           = wibox.widget.graph,
        color            = "linear:0,0:0,20:0,#FF0000:0.3,#FFFF00:0.6," .. color
    }

    local memory_widget           = wibox.container.margin(wibox.container.mirror(memorygraph_widget, { horizontal = true }), 2, 2, 2, 2)

    watch([[bash -c "cat /proc/meminfo"]], 1,
          function(widget, stdout)
              local _mem = { buf = {}, swp = {} }

              -- Get MEM info
              for line in stdout:gmatch("[^\r\n]+") do
                  for k, v in string.gmatch(line, "([%a]+):[%s]+([%d]+).+") do
                      if k == "MemTotal" then
                          _mem.total = math.floor(v / 1024)
                      elseif k == "MemFree" then
                          _mem.buf.f = math.floor(v / 1024)
                      elseif k == "MemAvailable" then
                          _mem.buf.a = math.floor(v / 1024)
                      elseif k == "Buffers" then
                          _mem.buf.b = math.floor(v / 1024)
                      elseif k == "Cached" then
                          _mem.buf.c = math.floor(v / 1024)
                      elseif k == "SwapTotal" then
                          _mem.swp.t = math.floor(v / 1024)
                      elseif k == "SwapFree" then
                          _mem.swp.f = math.floor(v / 1024)
                      end
                  end
              end

              -- Calculate memory percentage
              _mem.free      = _mem.buf.a
              _mem.inuse     = _mem.total - _mem.free
              _mem.bcuse     = _mem.total - _mem.buf.f
              _mem.usep      = math.floor(_mem.inuse / _mem.total * 100)
              -- Calculate swap percentage
              _mem.swp.inuse = _mem.swp.t - _mem.swp.f
              _mem.swp.usep  = math.floor(_mem.swp.inuse / _mem.swp.t * 100)

              widget:add_value(_mem.usep)
          end,
          memorygraph_widget
    )

    return memory_widget
end

return setmetatable(memory, {
    __call = memory.init
})

