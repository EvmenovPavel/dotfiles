local gtable     = require("gears.table")
local spawn      = require("awful.spawn")
local gmath      = require("gears.math")
local abutton    = require("awful.button")
local imagebox   = require("wibox.widget.imagebox")
local widget     = require("wibox.widget.base")
local surface    = require("gears.surface")
local cairo      = require("lgi").cairo
local keygrabber = keygrabber

local launcher   = {}
local button     = { button = button }
local wbutton    = {}

function wbutton:new(args)
    local args = args or {}

    if not args or not args.image then
        return widget.empty_widget()
    end

    local w              = imagebox()
    local orig_set_image = w.set_image
    local img_release
    local img_press

    function w:set_image(image)
        img_release = surface.load(image)
        img_press   = img_release:create_similar(cairo.Content.COLOR_ALPHA, img_release.width, img_release.height)
        local cr    = cairo.Context(img_press)
        cr:set_source_surface(img_release, 2, 2)
        cr:paint()
        orig_set_image(self, img_release)
    end

    w:set_image(args.image)
    w:buttons(abutton({}, 1, function()
        orig_set_image(w, img_press)
    end,
                      function()
                          orig_set_image(w, img_release)
                      end))

    w:connect_signal("mouse::leave", function(self)
        orig_set_image(self, img_release)
    end)

    return w
end

function button:new(args)
    local args             = args or {}

    local mod              = args.mod or {}
    local _button          = args._button or capi.event.mouse.button_click_left
    local press            = args.press or nil

    local mod_key          = capi.event.key.shift
    local key_switch       = capi.event.key.enter
    

    local release          = -- args.release or
    function()
        keygrabber.run(
                function(mod, keys, event)
                    if keys == key_switch and event == "press" then

                        local fun = args.release

                        fun()

                    elseif keys == mod_key and event == "release" then
                        keygrabber.stop()
                    end
                end
        )

        capi.log:message("args.release")
    end

    local ignore_modifiers = { "Lock", "Mod2" }

    local ret              = {}
    local subsets          = gmath.subsets(ignore_modifiers)

    for _, set in ipairs(subsets) do
        ret[#ret + 1] = self.button({
                                        modifiers = gtable.join(mod, set),
                                        button    = _button
                                    })
        if press then
            ret[#ret]:connect_signal("press", function(_, ...)
                press(...)
            end)
        end
        if release then
            ret[#ret]:connect_signal("release", function(_, ...)
                release(...)
            end)
        end
    end

    return ret
end

function launcher:init(args)
    local args = args or {}

    if not args.command and not args.menu then
        return
    end

    local w = wbutton:new(args)
    if not w then
        return
    end

    local b
    if args.command then
        b = gtable.join(w:buttons(),
                        button:new({
                                       release = function()
                                           spawn(args.command)
                                       end
                                   }))
    elseif args.menu then
        b = gtable.join(w:buttons(),
                        button:new({
                                       release = function()
                                           args.menu:toggle()
                                       end
                                   }))
    end

    w:buttons(b)
    return w
end

return setmetatable(launcher, { __call = function(_, ...)
    return launcher:init(...)
end })
