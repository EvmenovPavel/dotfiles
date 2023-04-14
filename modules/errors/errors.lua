local function get_context()
	local level   = 3

	local context = debug.getinfo(level)
	if not context then
		return true, nil
	end

	return false, context
end

awesome.connect_signal(
		"debug::error",
		function(err, t1, t2, t3)
			local msg_ = get_context()

			naughty.notify({
				preset = "preset",
				title  = "title",
				text   = err
			})

			local _, j = string.find(err, ".lua:")

			for i = j, #err do
				local c = err:sub(i, i)
				if (c == " ") then
					local source_linedefined = string.sub(err, 1, i)
					local msg                = string.sub(err, i, #err)

					wmapi:remove_space(source_linedefined)
					wmapi:remove_space(msg)

					log:debug("source: " .. source_linedefined)
					log:debug("msg: " .. msg)
				end
			end
		end
)

awesome.connect_signal(
		"debug::deprecation",
		function(msg, see, args)
			log:debug("debug::deprecation")
			log:debug("msg:", msg)
			log:debug("see:", see)
			log:debug("args:", args)
		end
)

awesome.connect_signal(
		"debug::index::miss",
		function(err)
			log:debug("debug::index::miss")
			log:debug("err:", err)
		end
)

awesome.connect_signal(
		"debug::newindex::miss",
		function(err)
			log:debug("debug::newindex::miss")
			log:debug("err:", err)
		end
)