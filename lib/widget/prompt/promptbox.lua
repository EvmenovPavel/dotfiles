local setmetatable = setmetatable

local prompt       = require("lib.widget.prompt.prompt")
local completion   = require("awful.completion")
local gfs          = require("gears.filesystem")
local spawn        = require("awful.spawn")
local beautiful    = require("beautiful")
local background   = require("wibox.container.background")
local type         = type

local widgetprompt = { mt = {} }

local function run(promptbox)
	return prompt.run {
		text                 = "TEST",
		prompt               = promptbox.prompt,
		textbox              = promptbox.widget,
		fg_cursor            = promptbox.fg_cursor,
		bg_cursor            = promptbox.bg_cursor,
		ul_cursor            = promptbox.ul_cursor,
		font                 = promptbox.font,
		autoexec             = promptbox.autoexec,
		highlighter          = promptbox.highlighter,
		exe_callback         = promptbox.exe_callback,
		completion_callback  = promptbox.completion_callback,
		history_path         = promptbox.history_path,
		history_max          = promptbox.history_max,
		done_callback        = promptbox.done_callback,
		changed_callback     = promptbox.changed_callback,
		keypressed_callback  = promptbox.keypressed_callback,
		keyreleased_callback = promptbox.keyreleased_callback,
		hook                 = promptbox.hook
	}
end

local function focus()
	return prompt.focus()
end

local function unfocus()
	return prompt.unfocus()
end

local function spawn_and_handle_error(self, ...)
	local f      = self.with_shell and spawn.with_shell or spawn
	local result = f(...)
	if type(result) == "string" then
		self.widget:set_text(result)
	end
end

function widgetprompt:init()
	local args       = {}
	local promptbox  = background()
	promptbox.widget = wmapi.widget:textbox()
	promptbox.widget:set_ellipsize("start")
	promptbox.run                    = run
	promptbox.focus                  = focus
	promptbox.unfocus                = unfocus
	promptbox.spawn_and_handle_error = spawn_and_handle_error
	promptbox.prompt                 = args.prompt or "Run: "
	promptbox.fg                     = args.fg or beautiful.prompt_fg or beautiful.fg_normal
	promptbox.bg                     = args.bg or beautiful.prompt_bg or beautiful.bg_normal
	promptbox.fg_cursor              = args.fg_cursor or nil
	promptbox.bg_cursor              = args.bg_cursor or nil
	promptbox.ul_cursor              = args.ul_cursor or nil
	promptbox.font                   = args.font or nil
	promptbox.autoexec               = args.autoexec or nil
	promptbox.highlighter            = args.highlighter or nil
	promptbox.exe_callback           = args.exe_callback or function(...)
		promptbox:spawn_and_handle_error(...)
	end
	promptbox.completion_callback    = args.completion_callback or completion.shell
	promptbox.history_path           = args.history_path or
			gfs.get_cache_dir() .. 'history'
	promptbox.history_max            = args.history_max or nil
	promptbox.done_callback          = args.done_callback or nil
	promptbox.changed_callback       = args.changed_callback or nil
	promptbox.keypressed_callback    = args.keypressed_callback or nil
	promptbox.keyreleased_callback   = args.keyreleased_callback or nil
	promptbox.hook                   = args.hook or nil

	return promptbox
end

return setmetatable(widgetprompt, { __call = function()
	return widgetprompt
end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
