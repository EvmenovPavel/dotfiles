local os       = os
local log_file = os.getenv("HOME") .. "/.config/awesome" .. "/log.file"

local logger   = {}

local function append(args)
    local args    = args or {}
    local level   = args.level or "nil"
    local message = args.message or args

    --logging.new(function(self, level, message)
    local file    = io.open(log_file, "a")
    if file then
        local date = os.date()
        file:write(tostring(date .. "\n" .. level .. ": " .. message), "\n\n")
        file:close()
    end
    --end)
end

function logger:message(...)
    local date = os.date()
    local msg  = date

    for i = 1, select("#", ...) do
        msg = msg .. "\n\t" .. tostring(select(i, ...))
    end

    local file = io.open(log_file, "a")
    if file then
        file:write(msg, "\n\n")
        file:close()
    end
end

return logger
