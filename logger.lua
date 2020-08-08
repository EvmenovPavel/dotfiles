local os      = os
local config  = require("config")

--local logging = require("lib.lualogging.logging")

local logger  = {}

local function append(args)
    local args    = args or {}
    local level   = args.level or "nil"
    local message = args.message or args

    --logging.new(function(self, level, message)
    local file    = io.open(config.logging, "a")
    if file then
        local date = os.date()
        file:write(tostring(date .. "\n" .. level .. ": " .. message), "\n\n")
        file:close()
    end
    --end)
end

function logger:message(args)
    append(args)
end

return logger
