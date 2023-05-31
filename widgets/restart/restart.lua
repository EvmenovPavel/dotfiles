local awful   = require("awful")
local gears   = require("gears")

local restart = {}

-- Функция для поиска иконки приложения по его имени или частичному имени
local function find_icon(name)
	local icon_path = awful.util.getdir("config") .. "icons/"
	local pattern   = "^" .. name:lower():gsub(" ", "_") .. ".*"
	local cmd       = "xdg-icon-resource"
	local prog      = cmd .. " --size 64 --novendor --size 32 --size 16 --theme hicolor --query " .. name
	local p         = io.popen(prog)

	local res       = p:read("*all")
	p:close()
	if res == "" then
		return nil
	end
	local icon_name = res:match(":%s+(.+)%s+\n")
	if icon_name ~= nil then
		local path = icon_path .. icon_name
		if gears.filesystem.file_readable(path) then
			return path
		end
	end
	for file in io.popen("ls " .. icon_path):lines() do
		if file:lower():match(pattern) ~= nil then
			local path = icon_path .. file
			if gears.filesystem.file_readable(path) then
				return path
			end
		end
	end
	return nil
end

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

	-- Пример использования функции find_icon()
	local icon_path = find_icon("firefox")
	if icon_path ~= nil then
		-- Использовать найденную иконку в качестве изображения
		local icon = gears.surface.load(icon_path)
		log:info("icon", icon)
		-- ...
	end

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
