-- Grab environment we need
local io          = io
local table       = table
local math        = math
local ipairs      = ipairs
local pcall       = pcall
local capi        = {
	selection = selection
}
local unpack      = unpack or table.unpack -- luacheck: globals unpack (compatibility with Lua 5.1)
local keygrabber  = require("awful.keygrabber")
local beautiful   = require("beautiful")
local akey        = require("awful.key")
local gdebug      = require('gears.debug')
local gtable      = require("gears.table")
local gcolor      = require("gears.color")
local gstring     = require("gears.string")
local gfs         = require("gears.filesystem")

local prompt      = {}

--- Private data
local data        = {}
data.history      = {}

local search_term = nil
local function itera (inc, a, i)
	i       = i + inc
	local v = a[i]
	if v then
		return i, v
	end
end

--- Load history file in history table
-- @param id The data.history identifier which is the path to the filename.
-- @param[opt] max The maximum number of entries in file.
local function history_check_load(id, max)
	if id and id ~= "" and not data.history[id] then
		data.history[id] = { max = 50, table = {} }

		if max then
			data.history[id].max = max
		end

		local f = io.open(id, "r")
		if not f then
			return
		end

		-- Read history file
		for line in f:lines() do
			if gtable.hasitem(data.history[id].table, line) == nil then
				table.insert(data.history[id].table, line)
				if #data.history[id].table >= data.history[id].max then
					break
				end
			end
		end
		f:close()
	end
end

local function is_word_char(c)
	if string.find("[{[(,.:;_-+=@/ ]", c) then
		return false
	else
		return true
	end
end

local function cword_start(s, pos)
	local i = pos
	if i > 1 then
		i = i - 1
	end
	while i >= 1 and not is_word_char(s:sub(i, i)) do
		i = i - 1
	end
	while i >= 1 and is_word_char(s:sub(i, i)) do
		i = i - 1
	end
	if i <= #s then
		i = i + 1
	end
	return i
end

local function cword_end(s, pos)
	local i = pos
	while i <= #s and not is_word_char(s:sub(i, i)) do
		i = i + 1
	end
	while i <= #s and is_word_char(s:sub(i, i)) do
		i = i + 1
	end
	return i
end

--- Save history table in history file
-- @param id The data.history identifier
local function history_save(id)
	if data.history[id] then
		gfs.make_parent_directories(id)
		local f = io.open(id, "w")
		if not f then
			gdebug.print_warning("Failed to write the history to " .. id)
			return
		end
		for i = 1, math.min(#data.history[id].table, data.history[id].max) do
			f:write(data.history[id].table[i] .. "\n")
		end
		f:close()
	end
end

--- Return the number of items in history table regarding the id
-- @param id The data.history identifier
-- @return the number of items in history table, -1 if history is disabled
local function history_items(id)
	if data.history[id] then
		return #data.history[id].table
	else
		return -1
	end
end

--- Add an entry to the history file
-- @param id The data.history identifier
-- @param command The command to add
local function history_add(id, command)
	if data.history[id] and command ~= "" then
		local index = gtable.hasitem(data.history[id].table, command)
		if index == nil then
			table.insert(data.history[id].table, command)

			-- Do not exceed our max_cmd
			if #data.history[id].table > data.history[id].max then
				table.remove(data.history[id].table, 1)
			end

			history_save(id)
		else
			-- Bump this command to the end of history
			table.remove(data.history[id].table, index)
			table.insert(data.history[id].table, command)
			history_save(id)
		end
	end
end


--- Draw the prompt text with a cursor.
-- @tparam table args The table of arguments.
-- @field text The text.
-- @field font The font.
-- @field prompt The text prefix.
-- @field text_color The text color.
-- @field cursor_color The cursor color.
-- @field cursor_pos The cursor position.
-- @field cursor_ul The cursor underline style.
-- @field selectall If true cursor is rendered on the entire text.
local function prompt_text_with_cursor(args)
	local char, spacer, text_start, text_end, ret
	local text      = args.text or ""
	local _prompt   = args.prompt or ""
	local underline = args.cursor_ul or "none"

	if args.selectall then
		if #text == 0 then
			char = " "
		else
			char = gstring.xml_escape(text)
		end
		spacer     = " "
		text_start = ""
		text_end   = ""
	elseif #text < args.cursor_pos then
		char       = " "
		spacer     = ""
		text_start = gstring.xml_escape(text)
		text_end   = ""
	else
		char       = gstring.xml_escape(text:sub(args.cursor_pos, args.cursor_pos))
		spacer     = " "
		text_start = gstring.xml_escape(text:sub(1, args.cursor_pos - 1))
		text_end   = gstring.xml_escape(text:sub(args.cursor_pos + 1))
	end

	local cursor_color = gcolor.ensure_pango_color(args.cursor_color)
	local text_color   = gcolor.ensure_pango_color(args.text_color)

	if args.highlighter then
		text_start, text_end = args.highlighter(text_start, text_end)
	end

	ret = _prompt .. text_start .. "<span background=\"" .. cursor_color ..
			"\" foreground=\"" .. text_color .. "\" underline=\"" .. underline ..
			"\">" .. char .. "</span>" .. text_end .. spacer
	return ret
end

function prompt.run(args, textbox, exe_callback, completion_callback,
                    history_path, history_max, done_callback,
                    changed_callback, keypressed_callback)
	local grabber
	local func
	local theme = beautiful.get()
	if not args then
		args = {}
	end
	local command      = args.text or ""
	local command_before_comp
	local cur_pos_before_comp
	local prettyprompt = args.prompt or ""
	local inv_col      = args.fg_cursor or theme.prompt_fg_cursor or theme.fg_focus or "black"
	local cur_col      = args.bg_cursor or theme.prompt_bg_cursor or theme.bg_focus or "white"
	local cur_ul       = args.ul_cursor
	local text         = args.text or ""
	local font         = args.font or theme.prompt_font or theme.font
	local selectall    = args.selectall
	local highlighter  = args.highlighter
	local hooks        = {}

	local deprecated   = function(name)
		gdebug.deprecate(string.format(
				'awful.prompt.run: the argument %s is deprecated, please use args.%s instead',
				name, name), { raw = true, deprecated_in = 4 })
	end
	if textbox then
		deprecated('textbox')
	end
	if exe_callback then
		deprecated('exe_callback')
	end
	if completion_callback then
		deprecated('completion_callback')
	end
	if history_path then
		deprecated('history_path')
	end
	if history_max then
		deprecated('history_max')
	end
	if done_callback then
		deprecated('done_callback')
	end
	if changed_callback then
		deprecated('changed_callback')
	end
	if keypressed_callback then
		deprecated('keypressed_callback')
	end

	-- This function has already an absurd number of parameters, allow them
	-- to be set using the args to avoid a "nil, nil, nil, nil, foo" scenario
	keypressed_callback = keypressed_callback or args.keypressed_callback
	changed_callback    = changed_callback or args.changed_callback
	done_callback       = done_callback or args.done_callback
	history_max         = history_max or args.history_max
	history_path        = history_path or args.history_path
	completion_callback = completion_callback or args.completion_callback
	exe_callback        = exe_callback or args.exe_callback
	textbox             = textbox or args.textbox

	if not textbox then
		return
	end

	search_term = nil

	history_check_load(history_path, history_max)
	local history_index = history_items(history_path) + 1
	-- The cursor position
	local cur_pos       = (selectall and 1) or text:wlen() + 1
	-- The completion element to use on completion request.
	local ncomp         = 1

	-- Build the hook map
	for _, v in ipairs(args.hooks or {}) do
		if #v == 3 then
			local _, key, callback = unpack(v)
			if type(callback) == "function" then
				hooks[key]                  = hooks[key] or {}
				hooks[key][#hooks[key] + 1] = v
			else
				gdebug.print_warning("The hook's 3rd parameter has to be a function.")
			end
		else
			gdebug.print_warning("The hook has to have 3 parameters.")
		end
	end

	textbox:set_font(font)
	textbox:set_markup(prompt_text_with_cursor {
		text         = text,
		text_color   = inv_col,
		cursor_color = cur_col,
		cursor_pos   = cur_pos,
		cursor_ul    = cur_ul,
		selectall    = selectall,
		prompt       = prettyprompt,
		highlighter  = highlighter
	})

	local function exec(cb, command_to_history)
		textbox:set_markup("")
		history_add(history_path, command_to_history)
		keygrabber.stop(grabber)
		if cb then
			cb(command)
		end
		if done_callback then
			done_callback()
		end
	end

	-- Update textbox
	local function update()
		textbox:set_font(font)
		textbox:set_markup(prompt_text_with_cursor {
			text         = command,
			text_color   = inv_col,
			cursor_color = cur_col,
			cursor_pos   = cur_pos,
			cursor_ul    = cur_ul,
			selectall    = selectall,
			prompt       = prettyprompt,
			highlighter  = highlighter
		})
	end

	func = function(modifiers, key, event)
		--log:debug("modifiers", modifiers, "key", key, "event", event)
		-- Convert index array to hash table
		local mod = {}
		for _, v in ipairs(modifiers) do
			mod[v] = true
		end

		if event ~= "press" then
			if args.keyreleased_callback then
				args.keyreleased_callback(mod, key, command)
			end

			return
		end

		-- Call the user specified callback. If it returns true as
		-- the first result then return from the function. Treat the
		-- second and third results as a new command and new prompt
		-- to be set (if provided)
		if keypressed_callback then
			local user_catched, new_command, new_prompt = keypressed_callback(mod, key, command)
			if new_command or new_prompt then
				if new_command then
					command = new_command
				end

				if new_prompt then
					prettyprompt = new_prompt
				end

				update()
			end

			if user_catched then
				if changed_callback then
					changed_callback(command)
				end

				return
			end
		end

		local filtered_modifiers = {}

		-- User defined cases
		if hooks[key] then
			-- Remove caps and num lock
			for _, m in ipairs(modifiers) do
				if not gtable.hasitem(akey.ignore_modifiers, m) then
					table.insert(filtered_modifiers, m)
				end
			end

			for _, v in ipairs(hooks[key]) do
				if #filtered_modifiers == #v[1] then
					local match = true
					for _, v2 in ipairs(v[1]) do
						match = match and mod[v2]
					end

					if match then
						local cb
						local ret, quit        = v[3](command)
						local original_command = command

						-- Support both a "simple" and a "complex" way to
						-- control if the prompt should quit.
						quit                   = quit == nil and (ret ~= true) or (quit ~= false)

						-- Allow the callback to change the command
						command                = (ret ~= true) and ret or command

						-- Quit by default, but allow it to be disabled
						if ret and type(ret) ~= "boolean" then
							cb = exe_callback
							if not quit then
								cur_pos = ret:wlen() + 1
								update()
							end
						elseif quit then
							-- No callback.
							cb = function()
							end
						end

						-- Execute the callback
						if cb then
							exec(cb, original_command)
						end

						return
					end
				end
			end
		end

		-- Get out cases
		if (mod.Control and (key == "c" or key == "g"))
				or (not mod.Control and key == "Escape") then
			prompt.unfocus()
		elseif (mod.Control and (key == "j" or key == "m"))
				or (not mod.Control and key == "Return")
				or (not mod.Control and key == "KP_Enter") then
			exec(exe_callback, command)
			-- We already unregistered ourselves so we don't want to return
			-- true, otherwise we may unregister someone else.
			return
		end

		-- Control cases
		if mod.Control then
			selectall = nil
			if key == "a" then
				cur_pos = 1
			elseif key == "b" then
				if cur_pos > 1 then
					cur_pos = cur_pos - 1
				end
			elseif key == "d" then
				if cur_pos <= #command then
					command = command:sub(1, cur_pos - 1) .. command:sub(cur_pos + 1)
				end
			elseif key == "p" then
				if history_index > 1 then
					history_index = history_index - 1

					command       = data.history[history_path].table[history_index]
					cur_pos       = #command + 2
				end
			elseif key == "n" then
				if history_index < history_items(history_path) then
					history_index = history_index + 1

					command       = data.history[history_path].table[history_index]
					cur_pos       = #command + 2
				elseif history_index == history_items(history_path) then
					history_index = history_index + 1

					command       = ""
					cur_pos       = 1
				end
			elseif key == "e" then
				cur_pos = #command + 1
			elseif key == "r" then
				search_term = search_term or command:sub(1, cur_pos - 1)
				for i, v in (function(a, i)
					return itera(-1, a, i)
				end), data.history[history_path].table, history_index do
					if v:find(search_term, 1, true) ~= nil then
						command       = v
						history_index = i
						cur_pos       = #command + 1
						break
					end
				end
			elseif key == "s" then
				search_term = search_term or command:sub(1, cur_pos - 1)
				for i, v in (function(a, i)
					return itera(1, a, i)
				end), data.history[history_path].table, history_index do
					if v:find(search_term, 1, true) ~= nil then
						command       = v
						history_index = i
						cur_pos       = #command + 1
						break
					end
				end
			elseif key == "f" then
				if cur_pos <= #command then
					cur_pos = cur_pos + 1
				end
			elseif key == "h" then
				if cur_pos > 1 then
					command = command:sub(1, cur_pos - 2) .. command:sub(cur_pos)
					cur_pos = cur_pos - 1
				end
			elseif key == "k" then
				command = command:sub(1, cur_pos - 1)
			elseif key == "u" then
				command = command:sub(cur_pos, #command)
				cur_pos = 1
			elseif key == "Up" then
				search_term = command:sub(1, cur_pos - 1) or ""
				for i, v in (function(a, i)
					return itera(-1, a, i)
				end), data.history[history_path].table, history_index do
					if v:find(search_term, 1, true) == 1 then
						command       = v
						history_index = i
						break
					end
				end
			elseif key == "Down" then
				search_term = command:sub(1, cur_pos - 1) or ""
				for i, v in (function(a, i)
					return itera(1, a, i)
				end), data.history[history_path].table, history_index do
					if v:find(search_term, 1, true) == 1 then
						command       = v
						history_index = i
						break
					end
				end
			elseif key == "w" or key == "BackSpace" then
				local wstart          = 1
				local wend            = 1
				local cword_start_pos = 1
				local cword_end_pos   = 1
				while wend < cur_pos do
					wend = command:find("[{[(,.:;_-+=@/ ]", wstart)
					if not wend then
						wend = #command + 1
					end
					if cur_pos >= wstart and cur_pos <= wend + 1 then
						cword_start_pos = wstart
						cword_end_pos   = cur_pos - 1
						break
					end
					wstart = wend + 1
				end
				command = command:sub(1, cword_start_pos - 1) .. command:sub(cword_end_pos + 1)
				cur_pos = cword_start_pos
			elseif key == "Delete" then
				-- delete from history only if:
				--  we are not dealing with a new command
				--  the user has not edited an existing entry
				if command == data.history[history_path].table[history_index] then
					table.remove(data.history[history_path].table, history_index)
					if history_index <= history_items(history_path) then
						command = data.history[history_path].table[history_index]
						cur_pos = #command + 2
					elseif history_index > 1 then
						history_index = history_index - 1

						command       = data.history[history_path].table[history_index]
						cur_pos       = #command + 2
					else
						command = ""
						cur_pos = 1
					end
				end
			end
		elseif mod.Mod1 or mod.Mod3 then
			if key == "b" then
				cur_pos = cword_start(command, cur_pos)
			elseif key == "f" then
				cur_pos = cword_end(command, cur_pos)
			elseif key == "d" then
				command = command:sub(1, cur_pos - 1) .. command:sub(cword_end(command, cur_pos))
			elseif key == "BackSpace" then
				local wstart = cword_start(command, cur_pos)
				command      = command:sub(1, wstart - 1) .. command:sub(cur_pos)
				cur_pos      = wstart
			end
		else
			if completion_callback then
				if key == "Tab" or key == "ISO_Left_Tab" then
					if key == "ISO_Left_Tab" or mod.Shift then
						if ncomp == 1 then
							return
						end
						if ncomp == 2 then
							command = command_before_comp
							textbox:set_font(font)
							textbox:set_markup(prompt_text_with_cursor {
								text       = command_before_comp, text_color = inv_col, cursor_color = cur_col,
								cursor_pos = cur_pos, cursor_ul = cur_ul, selectall = selectall,
								prompt     = prettyprompt })
							cur_pos = cur_pos_before_comp
							ncomp   = 1
							return
						end

						ncomp = ncomp - 2
					elseif ncomp == 1 then
						command_before_comp = command
						cur_pos_before_comp = cur_pos
					end
					local matches
					command, cur_pos, matches = completion_callback(command_before_comp, cur_pos_before_comp, ncomp)
					ncomp                     = ncomp + 1
					key                       = ""
					-- execute if only one match found and autoexec flag set
					if matches and #matches == 1 and args.autoexec then
						exec(exe_callback)
						return
					end
				elseif key ~= "Shift_L" and key ~= "Shift_R" then
					ncomp = 1
				end
			end

			-- Typin cases
			if mod.Shift and key == "Insert" then
				local selection = capi.selection()
				if selection then
					-- Remove \n
					local n = selection:find("\n")
					if n then
						selection = selection:sub(1, n - 1)
					end
					command = command:sub(1, cur_pos - 1) .. selection .. command:sub(cur_pos)
					cur_pos = cur_pos + #selection
				end
			elseif key == "Home" then
				cur_pos = 1
			elseif key == "End" then
				cur_pos = #command + 1
			elseif key == "BackSpace" then
				if cur_pos > 1 then
					command = command:sub(1, cur_pos - 2) .. command:sub(cur_pos)
					cur_pos = cur_pos - 1
				end
			elseif key == "Delete" then
				command = command:sub(1, cur_pos - 1) .. command:sub(cur_pos + 1)
			elseif key == "Left" then
				cur_pos = cur_pos - 1
			elseif key == "Right" then
				cur_pos = cur_pos + 1
			elseif key == "Up" then
				if history_index > 1 then
					history_index = history_index - 1

					command       = data.history[history_path].table[history_index]
					cur_pos       = #command + 2
				end
			elseif key == "Down" then
				if history_index < history_items(history_path) then
					history_index = history_index + 1

					command       = data.history[history_path].table[history_index]
					cur_pos       = #command + 2
				elseif history_index == history_items(history_path) then
					history_index = history_index + 1

					command       = ""
					cur_pos       = 1
				end
			else
				-- wlen() is UTF-8 aware but #key is not,
				-- so check that we have one UTF-8 char but advance the cursor of # position
				if key:wlen() == 1 then
					if selectall then
						command = ""
					end
					command = command:sub(1, cur_pos - 1) .. key .. command:sub(cur_pos)
					cur_pos = cur_pos + #key
				end
			end
			if cur_pos < 1 then
				cur_pos = 1
			elseif cur_pos > #command + 1 then
				cur_pos = #command + 1
			end
			selectall = nil
		end

		local success = pcall(update)
		while not success do
			-- TODO UGLY HACK TODO
			-- Setting the text failed. Most likely reason is that the user
			-- entered a multibyte character and pressed backspace which only
			-- removed the last byte. Let's remove another byte.
			if cur_pos <= 1 then
				-- No text left?!
				break
			end

			command = command:sub(1, cur_pos - 2) .. command:sub(cur_pos)
			cur_pos = cur_pos - 1
			success = pcall(update)
		end

		if changed_callback then
			changed_callback(command)
		end
	end

	function prompt.focus()
		grabber = keygrabber.run(func)
	end

	function prompt.unfocus()
		keygrabber.stop(grabber)
		--textbox:set_markup("")
		history_save(history_path)
		if done_callback then
			done_callback()
		end
		return false
	end

	command      = "TEST"
	inv_col      = "#e4e4e4"
	cur_col      = "#5A5A5A"
	cur_pos      = 5
	cur_ul       = nil
	selectall    = nil
	prettyprompt = "Run: "
	highlighter  = nil

	func({}, "3", "press")
	func({}, "3", "release")

	update()
end

return prompt

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
