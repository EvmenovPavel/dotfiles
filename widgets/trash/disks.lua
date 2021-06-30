local widget     = require("util.widgets")
local helpers    = require("helpers")
local wibox      = require("lib.wibox")
local beautiful  = require("lib.beautiful")
local dpi        = beautiful.xresources.apply_dpi
local sep        = require("util.separators")

-- beautiful vars
local fg         = beautiful.fg_primary

-- root
local disks_root = class()

function disks_root:init(args)
    -- options
    self.icon        = widget.base_icon("", beautiful.primary)
    self.title       = args.title or beautiful.widget_fs_title or { "FS", beautiful.fg_grey }
    self.title_size  = args.title_size or 10
    self.mode        = args.mode or 'text' -- possible values: text, arcchart, block
    self.want_layout = args.layout or beautiful.widget_cpu_layout or 'horizontal' -- possible values: horizontal , vertical
    self.bar_size    = args.bar_size or 100
    self.bar_colors  = args.bar_colors or beautiful.bar_colors or { beautiful.primary, beautiful.alert }
    -- base widgets
    self.wicon       = widget.base_icon()
    self.wtext       = widget.base_text()
    self.wtitle      = widget.create_title(self.title[1], self.title[2], self.title_size)
    self.wbars       = {} -- store all bars (one by cpu/core)
    self.widget      = self:make_widget()
end

function disks_root:make_widget()
    if self.mode == "arcchart" then
        return self:make_arcchart()
    elseif self.mode == "block" then
        return self:make_block()
    else
        return self:make_text()
    end
end

function disks_root:make_all_arcchart()
    for i = 1, #env.disks do
        if i >= 2 then
            -- trick to add circle in circle in circle
            self.wbars[i] = widget.make_arcchart(self.wbars[i - 1])
        else
            self.wbars[i] = widget.make_arcchart()
        end
    end
end

function disks_root:make_arcchart()
    self:make_all_arcchart()
    local w = wibox.widget {
        widget.box('horizontal', { self.wbars[#env.disks] }),
        nil,
        {
            nil,
            self.wtitle,
            nil,
            layout = wibox.layout.align.vertical
        },
        layout = wibox.layout.align.horizontal
    }
    -- signal
    awesome.connect_signal("daemon::disks", function(fs_info)
        if fs_info ~= nil and fs_info[1] ~= nil then
            for i = 1, #env.disks do
                self.wbars[i].value = fs_info[i].used_percent
            end
        end
    end)
    return w
end

function disks_root:make_progressbar_vert(bars, titles)
    local w = wibox.widget {
        {
            nil,
            widget.box('vertical', { self.wtitle, titles }),
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        {
            nil,
            bars,
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        spacing = 15,
        layout  = wibox.layout.fixed.horizontal
    }
    return w
end

function disks_root:make_block()
    for i = 1, #env.disks do
        self.wbars[i]                 = {}
        self.wbars[i]["title"]        = wibox.widget.textbox(env.disks[i])
        self.wbars[i]["used_percent"] = widget.make_progressbar(_, self.bar_size, { self.bar_colors[1][i], self.bar_colors[2] })
        self.wbars[i]["size"]         = wibox.widget.textbox()
    end

    local w
    if self.want_layout == 'horizontal' then
        w = wibox.widget { layout = wibox.layout.fixed.vertical }
        for i = 1, #env.disks do
            local t  = self.wbars[i].title -- box
            local u  = self.wbars[i].used_percent -- progressbar
            local s  = self.wbars[i].size -- text size
            local wx = wibox.widget {
                {
                    widget.box(self.want_layout, { self.icon, t, u, s }, 8),
                    widget = widget.progressbar_margin_horiz()
                },
                layout = wibox.layout.fixed.vertical
            }
            w:add(wx)
        end
    elseif self.want_layout == 'vertical' then
        local wp = wibox.widget { layout = wibox.layout.fixed.horizontal } -- progressbar
        local wn = wibox.widget { layout = wibox.layout.fixed.horizontal } -- fs names
        for i = 1, #env.disks do
            local n = wibox.widget.textbox(" " .. tostring(i))
            local t = self.wbars[i].title
            local u = widget.progressbar_layout(self.wbars[i].used_percent, self.want_layout)
            wp:add(widget.box(self.want_layout, { u, n }, 8))
            wn:add(widget.box('horizontal', { n, wibox.widget.textbox(":"), t, sep.pad(1) }))
        end
        w = self:make_progressbar_vert(wp, wn)
    end
    awesome.connect_signal("daemon::disks", function(fs_info)
        if fs_info ~= nil and fs_info[1] ~= nil then
            for i = 1, #env.disks do
                self.wbars[i].used_percent.value = fs_info[i].used_percent
                self.wbars[i].size.markup        = helpers.colorize_text(fs_info[i].size, beautiful.primary_light)
            end
        end
    end)
    return w
end

-- herit
local disks_widget = class(disks_root)

function disks_widget:init(args)
    disks_root.init(self, args)
    return self.widget
end

return disks_widget
