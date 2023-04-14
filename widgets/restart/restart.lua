local awful   = require("awful")

local restart = {}

function restart:init()
	-- {{{ Menu
	-- Create a launcher widget and a main menu
	local myawesomemenu = {
		{ "restart", function()
			awesome.restart()
		end },
		{ "quit", function()
			awesome.quit()
		end },
	}

	local mymainmenu    = awful.menu({
		items = {
			{ "awesome", myawesomemenu, resources.checkbox.checkbox },
			{ "open terminal", "kitty" }
		}
	})

	--local w             = wmapi.widget:switch()
	--w:image(resources.battery.caution)

	--w:checked(function()
	--    mymainmenu:toggle()
	--    --wmapi.widget:messagebox():information("app", "title", "text")
	--end)
	--
	--w:unchecked(function()
	--    mymainmenu:toggle()
	--    --wmapi.widget:messagebox():information("app", "title", "text")
	--end)

	local w             = wmapi.widget:button()

	w:imagebox():set_image(resources.checkbox.checkbox)

	w:clicked(function()
		local msg = wmapi.widget:messagebox()
		msg:information("App Name: Restart", "Title: Hello", "Привет. 100.", resources.battery.full)
	end)

	local int = 0
	local str = "restart" .. tostring(int)
	wmapi:update(function()
		int     = int + 1
		local t = w:textbox()

		--str     = str .. " " .. tostring(int)
		--t:text(str)
		--w:visible(not w:visible())
	end, 1)

	return w:get()
end

return setmetatable(restart, { __call = function()
	return restart:init()
end })
