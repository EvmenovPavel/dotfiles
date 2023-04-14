local dir     = {}

dir.home      = os.getenv("HOME")
dir.awesomewm = os.getenv("HOME") .. "/.config/awesome"
dir.devices   = os.getenv("HOME") .. "/.config/awesome/devices"

function dir:path(debug)
	local debug  = debug or debug

	local source = string.sub(debug.source, 2)
	local path   = string.sub(source, 1, string.find(source, "/[^/]*$"))

	return path
end

return dir