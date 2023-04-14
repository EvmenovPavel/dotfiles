local gears             = require("gears")
local color             = require("gears.color")
local cairo             = require("lgi").cairo
local surface           = require("gears.surface")
local timer             = require("gears.timer")

local root              = root

-- For set_source_pixbuf on a cairo context
--local _                 = require("lgi").Gdk

local wallpaper         = {}

-- Information about a pending wallpaper change, see prepare_context()
local pending_wallpaper = nil

local function root_geometry()
	local width, height = root.size()
	return { x = 0, y = 0, width = width, height = height }
end

local function get_screen(s)
	return s and screen[s]
end

--- Set the current wallpaper.
-- @param pattern The wallpaper that should be set. This can be a cairo surface,
--   a description for gears.color or a cairo pattern.
-- @see gears.color
function wallpaper.set(pattern)
	if cairo.Surface:is_type_of(pattern) then
		pattern = cairo.Pattern.create_for_surface(pattern)
	end
	if type(pattern) == "string" or type(pattern) == "table" then
		pattern = color(pattern)
	end
	if not cairo.Pattern:is_type_of(pattern) then
		error("wallpaper.set() called with an invalid argument")
	end
	root.wallpaper(pattern._native)
end

--- Prepare the needed state for setting a wallpaper.
-- This function returns a cairo context through which a wallpaper can be drawn.
-- The context is only valid for a short time and should not be saved in a
-- global variable.
-- @param s The screen to set the wallpaper on or nil for all screens
-- @return[1] The available geometry (table with entries width and height)
-- @return[1] A cairo context that the wallpaper should be drawn to
function wallpaper:prepare_context(s)
	s                             = get_screen(s)

	local root_width, root_height = root.size()
	local geom                    = s and s.geometry or root_geometry()
	local source, target, cr

	if not pending_wallpaper then
		-- Prepare a pending wallpaper
		source = surface(root.wallpaper())
		target = source:create_similar(cairo.Content.COLOR, root_width, root_height)

		-- Set the wallpaper (delayed)
		timer.delayed_call(function()
			local paper       = pending_wallpaper
			pending_wallpaper = nil
			wallpaper.set(paper.surface)
			paper.surface:finish()
		end)
	elseif root_width > pending_wallpaper.width or root_height > pending_wallpaper.height then
		-- The root window was resized while a wallpaper is pending
		source = pending_wallpaper.surface
		target = source:create_similar(cairo.Content.COLOR, root_width, root_height)
	else
		-- Draw to the already-pending wallpaper
		source = nil
		target = pending_wallpaper.surface
	end

	cr = cairo.Context(target)

	if source then
		-- Copy the old wallpaper to the new one
		cr:save()
		cr.operator = cairo.Operator.SOURCE
		cr:set_source_surface(source, 0, 0)
		cr:paint()
		cr:restore()
	end

	pending_wallpaper = {
		surface = target,
		width   = root_width,
		height  = root_height
	}

	-- Only draw to the selected area
	cr:translate(geom.x, geom.y)
	cr:rectangle(0, 0, geom.width, geom.height)
	cr:clip()

	return geom, cr
end

function wallpaper:set_animated(src, s)
	do
		-- For set_source_pixbuf on a cairo context
		local _ = require("lgi").Gdk
	end

	do
		local pixbuf   = require("lgi").GdkPixbuf
		local img, err = pixbuf.PixbufAnimation.new_from_file(src)
		if not img then
			log:debug("wallpaper:set_animated", err)
		else
			local iter = img:get_iter(nil)

			local function set_wp()
				local geom, cr = self:prepare_context(s)
				iter:advance(nil)
				cr:set_source_pixbuf(iter:get_pixbuf(), 0, 0)
				cr.operator = "SOURCE"
				cr:paint()
				local delay = iter:get_delay_time()
				if delay ~= -1 then
					gears.timer.start_new(delay / 1000, set_wp)
				end
			end
			set_wp()
		end
	end
end

function wallpaper:set_wallpaper(src, s)
	gears.wallpaper.maximized(src, s, true)
end

function wallpaper:init(s)
	--local src = "/home/be3yh4uk/.config/awesome/wallpapers/gif/wp2757868-wallpaper.gif"
	--return self:set_animated(src, s)

	local src = dir.awesomewm .. "/wallpapers/bg.png"
	self:set_wallpaper(src, s)
end

return setmetatable(wallpaper, { __call = function(_, ...)
	return wallpaper:init(...)
end })
