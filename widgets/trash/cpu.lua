local wibox     = require("lib.wibox")
local beautiful = require("lib.beautiful")
local widget    = require("util.widgets")
local helpers   = require("helpers")

-- beautiful vars
local fg        = beautiful.widget_cpu_fg or beautiful.fg_grey
local spacing   = beautiful.widget_spacing or 1

-- root
local cpu_root  = class()

function cpu_root:init(args)
    -- options
    self.mode        = args.mode or 'text' -- possible values: text, arcchart, progressbar, dotsbar
    self.want_layout = args.layout or beautiful.widget_cpu_layout or 'horizontal' -- possible values: horizontal , vertical
    self.cpus        = args.cpus or 2 -- number of cpu / core
    self.title       = args.title or beautiful.widget_cpu_title or { "CPU", beautiful.fg_grey }
    self.title_size  = args.title_size or 10
    -- base widgets
    self.wicon       = widget.base_icon()
    self.wtext       = widget.base_text()
    self.wtitle      = widget.create_title(self.title[1], self.title[2], self.title_size)
    self.wbars       = {} -- store all bars (one by cpu/core)
    self.wfreqs      = {} -- store all freqs (one by cpu/core)
    self.widget      = self:make_widget()
end

function cpu_root:make_widget()
    if self.mode == "arcchart" then
        return self:make_arcchart()
    elseif self.mode == "progressbar" then
        return self:make_progressbar()
    elseif self.mode == "dotsbar" then
        return self:make_dotsbar()
    else
        return self:make_text()
    end
end

function cpu_root:make_text()
    local w = widget.box_with_margin(self.want_layout, { self.wicon, self.wtext }, spacing)
    awesome.connect_signal("daemon::cpu", function(cpus)
        self.wicon.markup = helpers.colorize_text("x", fg)
        self.wtext.markup = helpers.colorize_text(cpus[1] .. '%', fg)
    end)
    return w
end

function cpu_root:make_all_arcchart()
    for i = 1, self.cpus do
        if i >= 2 then
            self.wbars[i] = widget.make_arcchart(self.wbars[i - 1])
        else
            self.wbars[i] = widget.make_arcchart()
        end
    end
end

function cpu_root:make_arcchart()
    self:make_all_arcchart()
    local w = wibox.widget {
        widget.box('horizontal', { self.wbars[self.cpus] }), -- left
        nil, -- nothing to middle
        { -- right
            nil,
            {
                self.wtitle,
                self.wtext,
                layout = wibox.layout.fixed.vertical
            },
            nil,
            layout = wibox.layout.align.vertical
        },
        layout = wibox.layout.align.horizontal
    }
    awesome.connect_signal("daemon::cpu", function(cpus)
        self.wtext.markup = helpers.colorize_text(cpus[1] .. "%", beautiful.fg_primary)
        self:update_wbars(cpus)
    end)
    return w
end

function cpu_root:update_wbars(cpus)
    for i = 1, self.cpus do
        self.wbars[i].value = tostring(cpus[i + 1]) -- the first entry do not count as a core
    end
end

function cpu_root:make_all_progressbar()
    for i = 1, self.cpus do
        self.wbars[i]               = widget.make_progressbar(_, 200)
        self.wbars[i].forced_height = 8
    end
end

function cpu_root:make_progressbar()
    self:make_all_progressbar()
    local w = widget.box('vertical', self.wbars)
    awesome.connect_signal("daemon::cpu", function(cpus)
        self:update_wbars(cpus)
    end)
    return w
end

function cpu_root:dotsbar_vert(freq)
    local t  = wibox.widget.textbox(self.cpus .. " Cores")
    local wb = wibox.widget { layout = wibox.layout.fixed.horizontal, spacing = 4 }
    for i = 1, self.cpus do
        wb:add(widget.box_with_bg(self.want_layout, self.wbars[i], -10, beautiful.grey))
    end
    local w = wibox.widget {
        {
            {
                nil,
                widget.box('vertical', { self.wtitle, freq }),
                expand = "none",
                layout = wibox.layout.align.vertical
            },
            wb,
            spacing = 15,
            layout  = wibox.layout.fixed.horizontal
        },
        top    = 8,
        bottom = 8,
        widget = wibox.container.margin
    }
    return w
end

function cpu_root:dotsbar_horiz(freq)
    local t = wibox.widget.textbox(self.cpus .. " Cores")
    local y, w, z
    y       = widget.box(self.want_layout, { t })
    w       = wibox.widget { layout = wibox.layout.fixed.vertical, spacing = 1 }
    z       = wibox.widget { layout = wibox.layout.fixed.vertical, spacing = 12 } -- adjust spacing, depend of the symbol used
    for i = 1, self.cpus do
        self.wfreqs[i] = widget.base_text()
        w:add(widget.box_with_bg(self.want_layout, self.wbars[i], 2, beautiful.grey))
        z:add(widget.box(self.want_layout, { self.wfreqs[i] }))
    end
    return wibox.widget {
        nil,
        {
            y,
            widget.box('horizontal', { w, z }, 10),
            layout = wibox.layout.fixed.vertical
        },
        nil,
        expand = "none",
        layout = wibox.layout.align.vertical
    }
end

function cpu_root:make_dotsbar()
    local bar = self.want_layout == 'vertical'
            and { size = 5, divisor = 18 } -- 100 / 18 = 5
            or { size = 8, divisor = 12 }

    for c = 1, self.cpus do
        self.wbars[c] = {}
        for i = 1, bar.size do
            table.insert(self.wbars[c], widget.create_text("", beautiful.grey_dark, beautiful.myfont .. " 12"))
        end
    end

    local freq = wibox.widget.textbox()

    local w    = self.want_layout == 'vertical'
            and self:dotsbar_vert(freq)
            or self:dotsbar_horiz(freq)

    awesome.connect_signal("daemon::cpu", function(cpus)
        local symbol = self.want_layout == "horizontal" and "" or ""
        freq.markup  = helpers.colorize_text(cpus[1] .. "%", beautiful.fg_grey)
        for c = 1, self.cpus do
            local val = math.floor(cpus[c + 1] / bar.divisor)
            if self.want_layout == "horizontal" then
                self.wfreqs[c].markup = helpers.colorize_text(cpus[c + 1] .. "%", beautiful.fg_grey_light)
            end
            for i = 1, bar.size do
                local color             = (val >= i and beautiful.alert or beautiful.grey_light)
                self.wbars[c][i].markup = helpers.colorize_text(symbol, color)
            end
        end
    end)
    return w
end

-- herit
local cpu_widget = class(cpu_root)

function cpu_widget:init(args)
    cpu_root.init(self, args)
    return self.widget
end

return cpu_widget
