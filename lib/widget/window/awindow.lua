local setmetatable  = setmetatable
local pairs         = pairs
local type          = type
local object        = require("gears.object")
local grect         = require("gears.geometry").rectangle
local beautiful     = require("beautiful")
local base          = require("wibox.widget.base")
local cairo         = require("lgi").cairo

local window        = { mt = {}, object = {} }
local drawable      = require("wibox.drawable")

local capi          = {
    drawin  = drawin,
    root    = root,
    awesome = awesome,
    screen  = screen
}

local force_forward = {
    shape_bounding = true,
    shape_clip     = true,
    shape_input    = true,
}

function window:set_widget(widget)
    self._drawable:set_widget(widget)
end

function window:get_widget()
    return self._drawable.widget
end

--wibox.setup = base.widget.setup

function window:set_bg(c)
    self._drawable:set_bg(c)
end

function window:set_bgimage(image, ...)
    self._drawable:set_bgimage(image, ...)
end

function window:set_fg(c)
    self._drawable:set_fg(c)
end

function window:find_widgets(x, y)
    return self._drawable:find_widgets(x, y)
end

function window:_apply_shape()
    local shape = self._shape

    if not shape then
        self.shape_bounding = nil
        self.shape_clip     = nil
        return
    end

    local geo = self:geometry()
    local bw  = self.border_width

    -- First handle the bounding shape (things including the border)
    local img = cairo.ImageSurface(cairo.Format.A1, geo.width + 2 * bw, geo.height + 2 * bw)
    local cr  = cairo.Context(img)

    -- We just draw the shape in its full size
    shape(cr, geo.width + 2 * bw, geo.height + 2 * bw)
    cr:set_operator(cairo.Operator.SOURCE)
    cr:fill()
    self.shape_bounding = img._native
    img:finish()

    -- Now handle the clip shape (things excluding the border)
    img = cairo.ImageSurface(cairo.Format.A1, geo.width, geo.height)
    cr  = cairo.Context(img)

    -- We give the shape the same arguments as for the bounding shape and draw
    -- it in its full size (the translate is to compensate for the smaller
    -- surface)
    cr:translate(-bw, -bw)
    shape(cr, geo.width + 2 * bw, geo.height + 2 * bw)
    cr:set_operator(cairo.Operator.SOURCE)
    cr:fill_preserve()
    -- Now we remove an area of width 'bw' again around the shape (We use 2*bw
    -- since half of that is on the outside and only half on the inside)
    cr:set_source_rgba(0, 0, 0, 0)
    cr:set_line_width(2 * bw)
    cr:stroke()
    self.shape_clip = img._native
    img:finish()
end

function window:set_shape(shape)
    self._shape = shape
    self:_apply_shape()
end

function window:get_shape()
    return self._shape
end

function window:set_input_passthrough(value)
    rawset(self, "_input_passthrough", value)

    if not value then
        self.shape_input = nil
    else
        local img        = cairo.ImageSurface(cairo.Format.A1, 0, 0)
        self.shape_input = img._native
        img:finish()
    end

    self:emit_signal("property::input_passthrough", value)
end

function window:get_input_passthrough()
    return self._input_passthrough
end

function window:get_screen()
    if self.screen_assigned and self.screen_assigned.valid then
        return self.screen_assigned
    else
        self.screen_assigned = nil
    end
    local sgeos = {}

    for s in capi.screen do
        sgeos[s] = s.geometry
    end

    return grect.get_closest_by_coord(sgeos, self.x, self.y)
end

function window:set_screen(s)
    s = capi.screen[s or 1]
    if s ~= self:get_screen() then
        self.x = s.geometry.x
        self.y = s.geometry.y
    end

    -- Remember this screen so things work correctly if screens overlap and
    -- (x,y) is not enough to figure out the correct screen.
    self.screen_assigned = s
    self._drawable:_force_screen(s)
end

function window:get_children_by_id(name)
    --TODO v5: Move the ID management to the hierarchy.
    if rawget(self, "_by_id") then
        return rawget(self, "_by_id")[name]
    elseif self._drawable.widget
            and self._drawable.widget._private
            and self._drawable.widget._private.by_id then
        return self._drawable.widget._private.by_id[name]
    end

    return {}
end

for _, k in pairs { "buttons", "struts", "geometry", "get_xproperty", "set_xproperty" } do
    window[k] = function(self, ...)
        return self.drawin[k](self.drawin, ...)
    end
end

local function setup_signals(_wibox)
    local obj
    local function clone_signal(name)
        -- When "name" is emitted on wibox.drawin, also emit it on wibox
        obj:connect_signal(name, function(_, ...)
            _wibox:emit_signal(name, ...)
        end)
    end

    obj = _wibox.drawin
    clone_signal("property::border_color")
    clone_signal("property::border_width")
    clone_signal("property::buttons")
    clone_signal("property::cursor")
    clone_signal("property::height")
    clone_signal("property::ontop")
    clone_signal("property::opacity")
    clone_signal("property::struts")
    clone_signal("property::visible")
    clone_signal("property::width")
    clone_signal("property::x")
    clone_signal("property::y")
    clone_signal("property::geometry")
    clone_signal("property::shape_bounding")
    clone_signal("property::shape_clip")
    clone_signal("property::shape_input")

    _wibox:emit_signal("request::titlebars", "awful.titlebar", {})

    obj = _wibox._drawable
    clone_signal("button::press")
    clone_signal("button::release")
    clone_signal("mouse::enter")
    clone_signal("mouse::leave")
    clone_signal("mouse::move")
    clone_signal("property::surface")
end

function window:init(args)
    args      = args or {}
    local ret = object()
    local w   = capi.drawin(args)

    function w.get_wibox()
        return ret
    end

    ret.drawin    = w
    ret._drawable = drawable(w.drawable, { wibox = ret },
            "wibox drawable (" .. object.modulename(3) .. ")")

    function ret._drawable.get_wibox()
        return ret
    end

    ret._drawable:_inform_visible(w.visible)
    w:connect_signal("property::visible", function()
        ret._drawable:_inform_visible(w.visible)
    end)

    for k, v in pairs(window) do
        if type(v) == "function" then
            ret[k] = v
        end
    end

    setup_signals(ret)
    ret.draw = ret._drawable.draw

    -- Set the default background
    ret:set_bg(args.bg or beautiful.bg_normal)
    ret:set_fg(args.fg or beautiful.fg_normal)

    -- Add __tostring method to metatable.
    local mt          = {}
    local orig_string = tostring(ret)
    mt.__tostring     = function()
        return string.format("wibox: %s (%s)",
                tostring(ret._drawable), orig_string)
    end
    ret               = setmetatable(ret, mt)

    -- Make sure the wibox is drawn at least once
    ret.draw()

    ret:connect_signal("property::geometry", ret._apply_shape)
    ret:connect_signal("property::border_width", ret._apply_shape)

    -- If a value is not found, look in the drawin
    setmetatable(ret, {
        __index    = function(self, k)
            if rawget(self, "get_" .. k) then
                return self["get_" .. k](self)
            else
                return w[k]
            end
        end,
        __newindex = function(self, k, v)
            if rawget(self, "set_" .. k) then
                self["set_" .. k](self, v)
            elseif force_forward[k] or w[k] ~= nil then
                w[k] = v
            else
                rawset(self, k, v)
            end
        end
    })

    return ret
end

-- Extend the luaobject
object.properties(capi.drawin, {
    getter_class = window.object,
    setter_class = window.object,
    auto_emit    = true,
})

return setmetatable(window, { __call = function()
    return window
end })
