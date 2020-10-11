local beautiful = require("lib.beautiful")
local widget    = require("util.widgets")
local helpers   = require("helpers")
local wibox     = require("lib.wibox")

-- beautiful vars
local fg        = beautiful.widget_ram_fg
local spacing   = beautiful.widget_spacing or 1

-- root
local ram_root  = class()

function ram_root:init(args)
    -- options
    self.icon        = args.icon or beautiful.widget_ram_icon or { "", "#000000" }
    self.title       = args.title or beautiful.widget_ram_title or { "RAM", "#000000" }
    self.title_size  = args.title_size or 10
    self.mode        = args.mode or 'text' -- possible values: text, progressbar, arcchart
    self.want_layout = args.layout or beautiful.widget_ram_layout or 'horizontal' -- possible values: horizontal , vertical
    self.bar_size    = args.bar_size or 200
    self.bar_colors  = args.bar_colors or beautiful.bar_colors or { beautiful.primary, beautiful.alert }
    -- base widgets
    self.wicon       = widget.base_icon(self.icon[1], self.icon[2])
    self.wtitle      = widget.create_title(self.title[1], self.title[2], self.title_size)
    self.wtext       = widget.base_text()
    self.widget      = self:make_widget()
end

function ram_root:make_widget()
    if self.mode == "arcchart" then
        return self:make_arcchart()
    elseif self.mode == "progressbar" then
        return self:make_progressbar()
    else
        return self:make_text()
    end
end

function ram_root:make_text()
    local w = widget.box_with_margin(self.want_layout, { self.wicon, self.wtext }, spacing)
    awesome.connect_signal("daemon::ram", function(mem)
        self.wtext.markup = helpers.colorize_text(mem.inuse_percent .. "%", fg)
    end)
    return w
end

function ram_root:make_arcchart()
    local arc = widget.make_arcchart()
    local w   = wibox.widget {
        { -- left
            nil,
            {
                nil,
                self.wtitle,
                self.text,
                layout = wibox.layout.fixed.vertical
            },
            nil,
            layout = wibox.layout.align.vertical
        },
        nil, -- nothing to center
        arc, -- right
        layout = wibox.layout.align.horizontal
    }
    awesome.connect_signal("daemon::ram", function(mem)
        arc.max_value     = mem.total
        arc.values        = { mem.inuse, mem.swp.inuse }
        self.wtext.markup = helpers.colorize_text(tostring(mem.inuse_percent) .. "%", beautiful.fg_primary)
    end)
    return w
end

function ram_root:make_progressbar_vert(p)
    local w = wibox.widget {
        {
            nil,
            widget.box('vertical', { self.wtitle, self.wtext }),
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        {
            nil,
            widget.box('vertical', { p, self.wicon }),
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        spacing = 15,
        layout  = wibox.layout.fixed.horizontal
    }
    return w
end

function ram_root:make_progressbar()
    local p  = widget.make_progressbar(_, self.bar_size, { self.bar_colors[1][1], self.bar_colors[2] })
    local wp = widget.progressbar_layout(p, self.want_layout)
    local w
    if self.want_layout == 'vertical' then
        w = self:make_progressbar_vert(wp)
    else
        w = widget.box_with_margin(self.want_layout, { self.wicon, wp }, 8)
    end
    awesome.connect_signal("daemon::ram", function(mem)
        p.value           = mem.inuse_percent
        self.wtext.markup = helpers.colorize_text(tostring(mem.total) .. " MB", beautiful.fg_grey)
    end)
    return w
end

-- herit
local ram_widget = class(ram_root)

function ram_widget:init(args)
    ram_root.init(self, args)
    return self.widget
end

return ram_widget
