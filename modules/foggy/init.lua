package.loaded.foggy = nil

local foggy          = {
	xrandr    = require('modules.foggy.xrandr'),
	xinerama  = require('modules.foggy.xinerama'),
	shortcuts = require('modules.foggy.shortcuts'),
	menu      = require('modules.foggy.menu')
}

return foggy
