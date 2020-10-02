local wbase        = require("wibox.widget.base")
local drawable     = require("wibox.drawable")
local beautiful    = require("beautiful")
local gtable       = require("gears.table")
--local capi              = {
--    awesome = awesome,
--    screen  = screen
--}
local setmetatable = setmetatable
local error        = error
local abs          = math.abs

local mysystray    = {
    --mt = {}
}

local instance     = nil
-- FIX
-- если виБар изменить положение в лево или право
-- то и положение систрей сделать false
-- для вертикаль (либо в конфиг изменять)
local horizontal   = true
local base_size    = nil
local reverse      = false
--local display_on_screen = "primary"

function mysystray:should_display_on(s)

    local primary = capi.primary or 1

    --if primary == "primary" then
    --    return s == capi.screen.primary
    --end

    --return s == display_on_screen
end

function mysystray:draw(context, cr, width, height)
    -- FIX
    -- передавать сюда размер виБара, тк, иконки не по центру
    local x, y, _, _  = wbase.rect_to_device_geometry(cr, 0, 0, width, height)
    local num_entries = capi.awesome.systray()

    local bg          = beautiful.bg_systray or beautiful.bg_normal or "#000000"

    local spacing     = beautiful.systray_icon_spacing or 0

    if context and not context.wibox then
        error("The systray widget can only be placed inside a wibox.")
    end

    -- Figure out if the cairo context is rotated
    local dir_x, dir_y = cr:user_to_device_distance(1, 0)
    local is_rotated   = abs(dir_x) < abs(dir_y)

    local in_dir, ortho, base
    if horizontal then
        in_dir, ortho = width, height
        is_rotated    = not is_rotated
    else
        ortho, in_dir = width, height
    end

    --if (ortho + spacing) * num_entries - spacing <= in_dir then
    if ortho * num_entries <= in_dir then
        base = ortho
    else
        base = in_dir / num_entries
        --base = (in_dir + spacing) / num_entries - spacing
    end
    capi.awesome.systray(context.wibox.drawin, math.ceil(x), math.ceil(y), base, is_rotated, bg, reverse, spacing)
end

function mysystray:_kickout(context)
    capi.awesome.systray(context.wibox.drawin)
end

function mysystray:fit(context, width, height)
    local num_entries = capi.awesome.systray()
    local base        = base_size
    local spacing     = beautiful.systray_icon_spacing or 0
    if num_entries == 0 then
        return 0, 0
    end
    if base == nil then
        if width < height then
            base = width
        else
            base = height
        end
    end
    base = base + spacing
    if horizontal then
        return base * num_entries - spacing, base
    end
    return base, base * num_entries - spacing
end

local function get_args(self, ...)
    if self == instance then
        return ...
    end
    return self, ...
end

function mysystray:set_base_size(size)
    base_size = get_args(self, size)
    if instance then
        instance:emit_signal("widget::layout_changed")
        instance:emit_signal("property::base_size", size)
    end
end

function mysystray:set_horizontal(horiz)
    horizontal = get_args(self, horiz)
    if instance then
        instance:emit_signal("widget::layout_changed")
    end
end

function mysystray:set_reverse(rev)
    reverse = get_args(self, rev)
    if instance then
        instance:emit_signal("widget::redraw_needed")
    end
end

function mysystray:set_screen(s)
    display_on_screen = get_args(self, s)
    if instance then
        instance:emit_signal("widget::layout_changed")
    end
end

function mysystray:init(revers)
    local ret = wbase.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(ret, mysystray, true)

    if revers then
        ret:set_reverse(true)
    end

    capi.awesome.connect_signal("systray::update", function()
        ret:emit_signal("widget::layout_changed")
        ret:emit_signal("widget::redraw_needed")
    end)
    capi.screen.connect_signal("primary_changed", function()
        if display_on_screen == "primary" then
            ret:emit_signal("widget::layout_changed")
        end
    end)

    drawable._set_systray_widget(ret)

    return ret
end

return setmetatable(mysystray, {
    __call = mysystray.init
})