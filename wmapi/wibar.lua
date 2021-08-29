local wibox     = require("wibox")
local beautiful = require("beautiful")
local gdebug    = require("gears.debug")
local placement = require("awful.placement")

local function get_screen(s)
    return s and capi.screen[s]
end

local mywibar = { mt = {} }

local function get_margins(w, args)
    local position = w.position
    assert(position)

    --FIX
    -- сюда надо как-то передать margins
    local margins = { left = args.left or 0, right = args.right or 0, top = args.top or 0, bottom = args.bottom or 0 }

    return margins
end

-- Create the placement function
local function gen_placement(position, stretch)
    local maximize = (position == "right" or position == "left") and
            "maximize_vertically" or "maximize_horizontally"

    return placement[position] + (stretch and placement[maximize] or nil)
end

-- Attach the placement function.
local function attach(wb, args, align)
    gen_placement(align, wb._stretch)(wb, {
        attach          = true,
        update_workarea = true,
        margins         = get_margins(wb, args)
    })
end

local function get_position(wb)
    return wb._position or "top"
end

--FIX
-- сюда надо передать top
local function set_position(wb, args, position, skip_reattach)
    -- Detach first to avoid any uneeded callbacks
    if wb.detach_callback then
        wb.detach_callback()

        -- Avoid disconnecting twice, this produces a lot of warnings
        wb.detach_callback = nil
    end

    -- In case the position changed, it may be necessary to reset the size
    if (wb._position == "left" or wb._position == "right")
            and (position == "top" or position == "bottom") then
        wb.height = math.ceil(beautiful.get_font_height(wb.font) * 1.5)
    elseif (wb._position == "top" or wb._position == "bottom")
            and (position == "left" or position == "right") then
        wb.width = math.ceil(beautiful.get_font_height(wb.font) * 1.5)
    end

    -- Set the new position
    wb._position = position

    -- Attach to the new position
    attach(wb, args, position)
end

local function get_stretch(w)
    return w._stretch
end

local function set_stretch(w, value)
    w._stretch = value
    attach(w, w.position)
end

function mywibar:get_position(wb)
    gdebug.deprecate("Use wb:get_position() instead of awful.mywibar.get_position", { deprecated_in = 4 })
    return get_position(wb)
end

function mywibar:set_position(wb, position, screen)
    gdebug.deprecate("Use wb:set_position(position) instead of awful.mywibar.set_position", { deprecated_in = 4 })

    set_position(wb, position)
end

function mywibar:attach(wb, position, screen)
    gdebug.deprecate("awful.mywibar.attach is deprecated, use the 'attach' property" ..
                             " of awful.placement. This method doesn't do anything anymore",
                     { deprecated_in = 4 }
    )
end

function mywibar:align(wb, align, screen)
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

function mywibar:init(args)
    args                 = args or {}
    local position       = args.position or "top"
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

    if args.visible == nil then
        w.visible = true
    end

    w:set_position(args, position, true)

    return w
end

return setmetatable(mywibar, {
    __call = mywibar.init
})
