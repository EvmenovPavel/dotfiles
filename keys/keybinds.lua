local awful     = require("awful")
local gears     = require("gears")
local beautiful = require("beautiful")

local hotkeys   = require("keys.hotkeys")

local keys      = {}

keys.globalkeys = require("keys.globalkeys")
keys.clientkeys = require("keys.clientkeys")
keys.buttonkeys = require("keys.buttonkeys")

for i in ipairs(beautiful.taglist_icons) do
	local descr_view, descr_toggle, descr_move, descr_toggle_focus
	if i == 1 or i == ipairs(root.tags()) then
		descr_view         = hotkeys.tag.view
		descr_toggle       = hotkeys.tag.toggle
		descr_move         = hotkeys.tag.move
		descr_toggle_focus = hotkeys.tag.toggle_focused
	end

	keys.globalkeys = gears.table.join(keys.globalkeys,
			awful.key({ event.key.mod }, i,
					function()
						local screen = awful.screen.focused()
						local tag    = screen.tags[i]
						if tag then
							tag:view_only()
						end
					end,
					descr_view),

			awful.key({ event.key.mod, event.key.shift }, i,
					function()
						if client.focus then
							local tag = client.focus.screen.tags[i]
							if tag then
								client.focus:move_to_tag(tag)
								local screen  = awful.screen.focused()
								local focused = screen.tags[i]
								if focused then
									focused:view_only()
								end
							end
						end
					end,
					descr_move)
	)
end

return keys