local setmetatable     = setmetatable
local gtable           = require("gears.table")
local abutton          = require("awful.button")
local widget           = require("wibox.widget.base")
local surface          = require("gears.surface")
local cairo            = require("lgi").cairo
local gmath            = require("gears.math")
local wibox            = require("wibox")

local capi             = { button = button }

local launcher         = { mt = {} }

local wbutton          = { mt = {} }
local button           = { mt = {} }

-- @table ignore_modifiers
local ignore_modifiers = { "Lock", "Mod2" }

function wbutton:new(args)
	local args = args or {}

	if not args or not args.image then
		return widget.empty_widget()
	end

	local w              = wmapi.widget:imagebox()
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
	w:buttons(abutton({}, 1,
			function() orig_set_image(w, img_press) end,
			function() orig_set_image(w, img_release) end))

	w:connect_signal("mouse::leave", function(self) orig_set_image(self, img_release) end)

	return w
end

function button:new(mod, _button, press, release)
	local ret     = {}
	local subsets = gmath.subsets(ignore_modifiers)
	for _, set in ipairs(subsets) do
		ret[#ret + 1] = capi.button({ modifiers = gtable.join(mod, set),
		                              button    = _button })
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
	local ret      = wmapi.widget:base("launcher")

	local w_button = wmapi.widget:button()
	w_button:clicked(function()
		args.menu:toggle()
	end)

	local w_textbox = w_button:textbox()
	w_textbox:text("test")

	local widget = wibox.widget({
		w_textbox:get(),
		widget = wibox.container.background,
	})


	--local __private = {}

	--if not args.command and not args.menu then return end

	--local w = wbutton:new(args)
	--if not w then
	--    return
	--end
	--
	--w:buttons(gtable.join(w:buttons(),
	--        button:new({}, 1, nil, function()
	--            args.menu:toggle()
	--        end)))

	function ret:get()
		return widget
	end

	return ret
end

return setmetatable(launcher, { __call = function()
	return launcher
end })
