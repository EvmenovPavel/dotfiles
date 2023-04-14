---@class widget

-- Include libs --
require("lib.lib")

-- Include modules --
require("modules.modules")

---@overload fun(message:string)
---@param message string
function error(message)
	log:error(message)
end

-- Global type --
require("resources.resources")

-- Start --
require("main")
