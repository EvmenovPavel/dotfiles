local wibox       = require("wibox")

local memory      = {}

local memory_rows = {
    spacing = 4,
    layout  = wibox.layout.fixed.vertical,
}

function row(name, str)
    local row = wibox.widget {
        widget:textbox(name),
        widget:textbox(str),
        layout = wibox.layout.ratio.horizontal
    }

    row:ajust_ratio(2, 0.15, 0.15, 0.7)

    return row
end

local function init()
    local bash                  = [[bash -c "cat /proc/meminfo"]]

    local wTextBox              = widget:textbox()
    wTextBox:get().forced_width = 80

    local popup                 = widget:popup({
        top    = 12,
        left   = 4,
        bottom = 4,
        right  = 4,

        widget = wibox.container.margin,
    })

    wmapi:watch(bash, 3,
            function(stdout)
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
                _mem.swp.inuse = _mem.swp.t - _mem.swp.f
                _mem.swp.usep  = math.floor(_mem.swp.inuse / _mem.swp.t * 100)

                --wTextBox.markup = "Mem [" .. tostring(_mem.usep) .. "%]"

                memory_rows[1] = row("free", _mem.free)
                memory_rows[2] = row("inuse", _mem.inuse)
                memory_rows[3] = row("bcuse", _mem.bcuse)
                memory_rows[4] = row("usep", _mem.usep)
                memory_rows[5] = row("swp.inuse", _mem.swp.inuse)
                memory_rows[6] = row("swp.usep", _mem.swp.usep)

                popup:setup {
                    capi.containers.margin({ widget = memory_rows }),
                    layout = wibox.layout.fixed.vertical,
                }
            end)

    --local wText = wibox.container.margin(wibox.container.mirror(wTextBox:get(), { horizontal = false }), 2, 2, 2, 2)
    --wText
    local w    = widget:button()

    local func = function()
        if popup.visible then
            popup.visible = not popup.visible
        else
            popup:move_next_to(mouse.current_widget_geometry)
        end
    end

    --w:set_func(func)

    return w:get()
end

return setmetatable(memory, { __call = function(_, ...)
    return init(...)
end })
