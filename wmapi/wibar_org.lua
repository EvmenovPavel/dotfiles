local capi         = {
    screen = screen,
    client = client
}
local setmetatable = setmetatable
local tostring     = tostring
local ipairs       = ipairs
local error        = error
local wibox        = require("wibox")
local beautiful    = require("beautiful")
local gdebug       = require("gears.debug")
local placement    = require("awful.placement")

local function get_screen(s)
    return s and capi.screen[s]
end

local awfulmywibar = { mt = {} }

local wiboxes      = setmetatable({}, { __mode = "v" })

local function get_margin(w, position, auto_stop)
    local h_or_w = (position == "top" or position == "bottom") and "height" or "width"
    local ret    = 0

    for _, v in ipairs(wiboxes) do
        -- Ignore the mywibars placed after this one
        if auto_stop and v == w then
            break
        end

        if v.position == position and v.screen == w.screen and v.visible then
            ret = ret + v[h_or_w]
        end
    end

    return ret
end

local function get_margins(w)
    local position = w.position
    assert(position)

    local margins     = { left = 0, right = 0, top = 0, bottom = 0 }

    margins[position] = get_margin(w, position, true)

    -- Avoid overlapping mywibars
    if position == "left" or position == "right" then
        margins.top    = get_margin(w, "top")
        margins.bottom = get_margin(w, "bottom")
    end

    return margins
end

local function gen_placement(position, stretch)
    local maximize = (position == "right" or position == "left") and
            "maximize_vertically" or "maximize_horizontally"

    return placement[position] + (stretch and placement[maximize] or nil)
end

-- Attach the placement function.
local function attach(wb, align)
    gen_placement(align, wb._stretch)(wb, {
        attach          = true,
        update_workarea = wb._workarea,
        margins         = get_margins(wb)
    })
end

local function reattach(wb)
    local s = wb.screen
    for _, w in ipairs(wiboxes) do
        if w ~= wb and w.screen == s then
            if w.detach_callback then
                w.detach_callback()
                w.detach_callback = nil
            end
            attach(w, w.position, w.workarea)
        end
    end
end

local function get_position(wb)
    return wb._position or "top"
end

local function set_position(wb, position, workarea, skip_reattach)
    -- Detach first to avoid any uneeded callbacks
    if wb.detach_callback then
        wb.detach_callback()

        -- Avoid disconnecting twice, this produces a lot of warnings
        wb.detach_callback = nil
    end

    if wb._position then
        for k, w in ipairs(wiboxes) do
            if w == wb then
                table.remove(wiboxes, k)
            end
        end
        table.insert(wiboxes, wb)
    end

    -- In case the position changed, it may be necessary to reset the size
    if (wb._position == "left" or wb._position == "right")
            and (position == "top" or position == "bottom") then
        wb.height = math.ceil(beautiful.get_font_height(wb.font) * 1.5)
    elseif (wb._position == "top" or wb._position == "bottom")
            and (position == "left" or position == "right") then
        wb.width = math.ceil(beautiful.get_font_height(wb.font) * 1.5)
    end

    wb._position = position
    wb._workarea = workarea

    attach(wb, position)

    if not skip_reattach then
        reattach(wb)
    end
end

local function get_stretch(w)
    return w._stretch
end

local function set_stretch(w, value, workarea)
    w._stretch = value
    attach(w, w.position, workarea)
end

local function remove(self)
    self.visible = false

    if self.detach_callback then
        self.detach_callback()
        self.detach_callback = nil
    end

    for k, w in ipairs(wiboxes) do
        if w == self then
            table.remove(wiboxes, k)
        end
    end

    self._screen = nil
end

function awfulmywibar.get_position(wb)
    gdebug.deprecate("Use wb:get_position() instead of awful.mywibar.get_position", { deprecated_in = 4 })
    return get_position(wb)
end

function awfulmywibar.set_position(wb, position, workarea, screen)
    gdebug.deprecate("Use wb:set_position(position) instead of awful.mywibar.set_position", { deprecated_in = 4 })

    set_position(wb, position, workarea)
end

function awfulmywibar.attach(wb, position, workarea, screen)
    --luacheck: no unused args
    gdebug.deprecate("awful.mywibar.attach is deprecated, use the 'attach' property" ..
                             " of awful.placement. This method doesn't do anything anymore",
                     { deprecated_in = 4 }
    )
end

function awfulmywibar.align(wb, align, workarea, screen)
    if align == "center" then
        gdebug.deprecate("awful.mywibar.align(wb, 'center' is deprecated, use 'centered'", { deprecated_in = 4 })
        align = "centered"
    end

    if screen then
        gdebug.deprecate("awful.mywibar.align 'screen' argument is deprecated", { deprecated_in = 4 })
    end

    if placement[align] then
        return placement[align](wb)
    end
end

function awfulmywibar.new(args)
    args                 = args or {}
    local position       = args.position or "top"
    local workarea       = args.workarea == nil and true or args.workarea
    local has_to_stretch = true
    local screen         = get_screen(args.screen or 1)

    args.type            = args.type or "dock"

    if position ~= "top" and position ~= "bottom"
            and position ~= "left" and position ~= "right" then
        error("Invalid position in awful.mywibar(), you may only use"
                      .. " 'top', 'bottom', 'left' and 'right'")
    end

    -- Set default size
    if position == "left" or position == "right" then
        args.width = args.width or beautiful["mywibar_width"]
                or math.ceil(beautiful.get_font_height(args.font) * 1.5)
        if args.height then
            has_to_stretch = false
            if args.screen then
                local hp = tostring(args.height):match("(%d+)%%")
                if hp then
                    args.height = math.ceil(screen.geometry.height * hp / 100)
                end
            end
        end
    else
        args.height = args.height or beautiful["mywibar_height"]
                or math.ceil(beautiful.get_font_height(args.font) * 1.5)
        if args.width then
            has_to_stretch = false
            if args.screen then
                local wp = tostring(args.width):match("(%d+)%%")
                if wp then
                    args.width = math.ceil(screen.geometry.width * wp / 100)
                end
            end
        end
    end

    args.screen = nil

    -- The C code scans the table directly, so metatable magic cannot be used.
    for _, prop in ipairs { "border_width", "border_color", "font", "opacity", "ontop", "cursor",
                            "bgimage", "bg", "fg", "type", "stretch", "shape" } do
        if (args[prop] == nil) and beautiful["mywibar_" .. prop] ~= nil then
            args[prop] = beautiful["mywibar_" .. prop]
        end
    end

    local w        = wibox(args)

    w.screen       = screen
    w._screen      = screen --HACK When a screen is removed, then getbycoords wont work
    w._stretch     = args.stretch == nil and has_to_stretch or args.stretch

    w.get_position = get_position
    w.set_position = set_position

    w.get_stretch  = get_stretch
    w.set_stretch  = set_stretch
    w.remove       = remove

    if args.visible == nil then
        w.visible = true
    end

    w:set_position(position, workarea, true)

    table.insert(wiboxes, w)

    reattach(w)

    w:connect_signal("property::visible", function()
        reattach(w)
    end)

    return w
end

capi.screen.connect_signal("removed", function(s)
    local mywibars = {}
    for _, mywibar in ipairs(wiboxes) do
        if mywibar._screen == s then
            table.insert(mywibars, mywibar)
        end
    end
    for _, mywibar in ipairs(mywibars) do
        mywibar:remove()
    end
end)

function awfulmywibar.mt:__call(...)
    return awfulmywibar.new(...)
end

return setmetatable(awfulmywibar, awfulmywibar.mt)