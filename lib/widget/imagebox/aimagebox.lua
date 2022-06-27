local wibox    = require("wibox")

--local glib     = require("lgi").GLib
--local timer    = require("gears.timer")
--local DateTime = glib.DateTime
--local TimeZone = glib.TimeZone

local imagebox = {}

--- This lowers the timeout so that it occurs "correctly". For example, a timeout
-- of 60 is rounded so that it occurs the next time the clock reads ":00 seconds".
--local function calc_timeout(real_timeout)
--    return real_timeout - os.time() % real_timeout
--end
--
--function private.imagebox_update_cb()
--    --ret.widget:set_image(private.image)
--
--    ret._timer.timeout = calc_timeout(private.refresh)
--    ret._timer:again()
--
--    return true -- Continue the timer
--
--
--    --private.update()
--    --ret.widget:reset()
--
--    --ret.widget:set_image(private.image)
--
--    --ret.widget:set_resize(private.resize)
--
--    --log:debug("local function update")
--end
--
--ret._timer = timer.weak_start_new(private.timeout, private.imagebox_update_cb)
--ret._timer:emit_signal("timeout")

--private.timeout       = argc.timeout or 1
--private.refresh       = argc.refresh or 1
--private.timezone      = TimeZone.new()
--private.format        = argc.format or " %a %b %d, %H:%M "


function imagebox:init(image, resize, forced_width, forced_height, clip_shape)
    local ret             = wmapi:widget():base("imagebox")

    local private         = {}

    private.image         = image or nil
    private.resize        = resize or true
    private.forced_width  = forced_width or nil
    private.forced_height = forced_height or nil
    private.clip_shape    = clip_shape or nil

    local widget          = wibox.widget({
                                             image         = private.image,

                                             resize        = private.resize,
                                             forced_width  = private.forced_width,
                                             forced_height = private.forced_height,

                                             widget        = wibox.widget.imagebox(),
                                         })

    --ret.widget:emit_signal("widget::layout_changed")
    --ret.widget:emit_signal("widget::reset")

    local function imagebox_update()
        widget:set_image(private.image)
        widget:set_resize(private.resize)

        --ret.widget.forced_width  = private.forced_width
        --ret.widget.forced_height = private.forced_width
    end

    function ret:set_image(image)
        private.image = image or nil
        imagebox_update()
    end

    function ret:set_width(width)
        private.forced_width = width or 0
        imagebox_update()
    end

    function ret:set_height(height)
        private.forced_height = height or 0
        imagebox_update()
    end

    function ret:set_resize(resize)
        private.resize = resize or true
        imagebox_update()
    end

    --function ret:set_clip_shape(clip_shape, ...)
    --    private.clip_shape = clip_shape or true
    --    ret._private:imagebox_update()
    --end

    --function imagebox:draw(cr, width, height)
    --
    --end

    --function imagebox:fit(width, height)
    --
    --end

    function ret:get()
        imagebox_update()
        return widget
    end

    return ret
end

return imagebox