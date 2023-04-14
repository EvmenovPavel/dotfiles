local awful     = require("awful")
local beautiful = require("beautiful")

local rules     = {}

local function init(clientkeys, buttonkeys)
	return {
		rule_any   = {
			type = {
				"normal",
				"dialog"
			}
		},
		properties = {
			titlebars_enabled = beautiful.titlebars_enabled or true,

			border_width      = beautiful.border_width,
			border_color      = beautiful.border_normal,

			focus             = awful.client.focus.filter,

			raise             = true,

			keys              = clientkeys,
			buttons           = buttonkeys,

			screen            = awful.screen.preferred,
			placement         = awful.placement.centered,

			--shape             = function()
			--    return function(cr, w, h)
			--        gears.shape.rounded_rect(cr, w, h, 7)
			--    end
			--end,

			--gears.shape.rounded_rect,
			callback          = function(c, startup)
				-- обновляет края окон
				wmapi:update_client(c)

				--wmapi:client_info(c)
			end
		}
	}
end

return setmetatable(rules, { __call = function(_, ...)
	return init(...)
end })