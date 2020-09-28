---------------------------------------------------------------------------
-- @author Uli Schlachter (based on ideas from Saleur Geoffrey)
-- @copyright 2015 Uli Schlachter
-- @release @AWESOME_VERSION@
-- @classmod wibox.layout.scroll
---------------------------------------------------------------------------

local cache     = require("lib.gears.cache")
local timer     = require("lib.gears.timer")
local hierarchy = require("lib.wibox.hierarchy")
local base      = require("lib.wibox.widget.base")
local lgi       = require("lib.lgi")
local GLib      = lgi.GLib
local cairo     = lgi.cairo

local scroll    = {}
local scroll_mt = { __index = scroll }

local function clean_context(context)
    local skip = { wibox = true, drawable = true, client = true, position = true }
    local res  = {}
    for k, v in pairs(context) do
        if not skip[k] then
            res[k] = v
        end
    end
    return res
end

local function create_surface(context, widget, width, height)
    local context = clean_context(context)
    local surface = cairo.ImageSurface(cairo.Format.ARGB32, width, height)
    local layouts = setmetatable({}, { __mode = "k" })

    -- Create a widget hierarchy and make sure the surface is always up to date.
    -- This isn't being clever: Things are not delayed until later and we always
    -- do a full redraw. (TODO: Be clever)
    local hier
    local cb_arg  = {}
    local function redraw_callback(h, arg)
        if arg ~= cb_arg then
            return
        end

        -- Update our surface
        local cr = cairo.Context(surface)
        cr:save()
        cr.operator = cairo.Operator.SOURCE
        cr:set_source_rgba(0, 0, 0, 0)
        cr:paint()
        cr:restore()
        hier:draw(context, cr)
        assert(cr.status == "SUCCESS", "Cairo context entered error state: " .. cr.status)

        -- Make the scroll layout(s) redraw
        for w in pairs(layouts) do
            w:emit_signal("widget::redraw_needed")
        end
    end
    local function layout_callback(h, arg)
        --hier:update(context, widget, width, height)
        if arg ~= cb_arg then
            return
        end
        cb_arg = {}
        hier   = hierarchy.new(context, widget, width, height, redraw_callback, layout_callback, cb_arg)
        redraw_callback(h, cb_arg)
    end
    --[[
    hier = hierarchy.new(context, widget, width, height, redraw_callback, layout_callback, nil)
    redraw_callback()
    --]]
    layout_callback(nil, cb_arg)

    return surface, layouts
end
local surface_cache = cache.new(create_surface)

--- Draw this scrolling layout.
-- @param context The context in which we are drawn.
-- @param cr The cairo context to draw to.
-- @param width The available width.
-- @param height The available height.
function scroll:draw(context, cr, width, height)
    if not self.widget then
        return
    end
    local surface_width, surface_height    = width, height
    local extra_width, extra_height, extra = 0, 0, self.expand and self.extra_space or 0
    local w, h
    if self.dir == "h" then
        w, h          = base.fit_widget(self, context, self.widget, self.space_for_scrolling, height)
        surface_width = w
        extra_width   = extra
    else
        w, h           = base.fit_widget(self, context, self.widget, width, self.space_for_scrolling)
        surface_height = h
        extra_height   = extra
    end
    if w > width or h > height then
        surface_width, surface_height = surface_width + extra_width, surface_height + extra_height
        if not self.paused then
            self:_need_scroll_redraw()
        end
    end
    local surface, layouts = surface_cache:get(context, self.widget, surface_width, surface_height)
    layouts[self]          = true
    local x, y             = 0, 0
    if w > width or h > height then
        local function get_scroll_offset(size, visible_size)
            return self.step_function(self.timer:elapsed(), size, visible_size, self.speed, self.extra_space)
        end
        if self.dir == "h" then
            x = -get_scroll_offset(surface_width - extra, width)
        else
            y = -get_scroll_offset(surface_height - extra, height)
        end
        cr:set_source_surface(surface, x, y)
        cr:paint()
        -- Was the extra space already included elsewhere?
        local extra = self.expand and 0 or self.extra_space
        if self.dir == "h" then
            x = x + surface_width + extra
        else
            y = y + surface_height + extra
        end
    end
    cr:set_source_surface(surface, x, y)
    cr:paint()
end

--- Reset scroll
function scroll:reset()
    if not self.stoped then
        self.timer:reset()
        self.stoped = true
        self:emit_signal("widget::redraw_needed")
    end
end

function scroll:pause()
    if not self.paused then
        self.timer:stop()
        self.paused = true
        self:emit_signal("widget::redraw_needed")
    end
end

function scroll:start()
    if self.paused or self.stoped then
        self.timer:continue()
        self.paused = false
        self.stoped = false
        self:emit_signal("widget::redraw_needed")
    end

end
--- Fit the scroll layout into the given space.
-- @param context The context in which we are fit.
-- @param width The available width.
-- @param height The available height.
function scroll:fit(context, width, height)
    if not self.widget then
        return 0, 0
    end
    local w, h = base.fit_widget(self, context, self.widget, width, height)
    if self.max_size then
        if self.dir == "h" then
            w = math.min(w, self.max_size)
        else
            h = math.min(h, self.max_size)
        end
    end
    return w, h
end

function scroll:_need_scroll_redraw()
    if not self.scroll_timer then
        self.scroll_timer = timer.start_new(1 / self.fps, function()
            self.scroll_timer = nil
            self:emit_signal("widget::redraw_needed")
        end)
    end
end

local function get_layout(dir, widget, fps, speed, extra_space, expand, max_size, step_function, space_for_scrolling)
    local ret               = base.make_widget()
    ret.stoped              = false
    ret.paused              = false
    ret.timer               = GLib.Timer()
    ret.dir                 = dir
    ret.widget              = widget
    ret.fps                 = fps or 20
    ret.speed               = speed or 10
    ret.extra_space         = extra_space or 0
    ret.max_size            = max_size
    ret.expand              = expand
    ret.space_for_scrolling = space_for_scrolling or 2 ^ 1024
    ret.scroll_timer        = nil
    ret.step_function       = step_function or function(elapsed, size, visible_size, speed, extra_space)
        return (elapsed * speed) % (size + extra_space)
    end

    return setmetatable(ret, scroll_mt)
end

function scroll.horizontal(widget, fps, speed, extra_space, expand, max_size, step_function, space_for_scrolling)
    return get_layout("h", widget, fps, speed, extra_space, expand, max_size, step_function, space_for_scrolling)
end

function scroll.vertical(widget, fps, speed, extra_space, expand, max_size, step_function, space_for_scrolling)
    return get_layout("v", widget, fps, speed, extra_space, expand, max_size, step_function, space_for_scrolling)
end
-- Add expand mode

return scroll

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80