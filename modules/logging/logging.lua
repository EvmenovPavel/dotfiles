local TypeLog          = {
    DEBUG   = "DEBUG",
    INFO    = "INFO",
    WARNING = "WARNING",
    ERROR   = "ERROR",
    FATAL   = "FATAL",
}

local logging          = {}

local date_time_format = "%Y-%m-%d %H:%M:%S"
local filename         = "logging.log"

function write_file(message)
    local path     = os.getenv("HOME") .. "/.config/awesome/"

    local file     = io.open(path .. filename, "a")
    if file then
        file:write(message, "\n")
        file:close()
        return false
    end

    return true
end

function message(type, ...)
    local date = os.date(date_time_format)

    local msg
    for i = 1, select("#", ...) do
        local item = select(i, ...)
        if ((msg == nil) or (msg == "")) then
            msg = tostring(item)
        else
            msg = msg .. " " .. tostring(item)
        end
    end

    if ((msg == nil) or (msg == "")) then
        return true
    else
        msg = date .. ", [" .. capi.wmapi:get_pid() .. "] " .. type .. " > " .. msg
        return write_file(msg)
    end
end

function logging:set_format(format)
    date_time_format = format
end

function logging:file_name(name)
    filename = name
end

-- Logs a message with DEBUG level.
function logging:debug(...)
    message(TypeLog.DEBUG, ...)
end

-- Logs a message with INFO level.
function logging:info(...)
    message(TypeLog.INFO, ...)
end

-- Logs a message with WARNING level.
function logging:warning(...)
    message(TypeLog.WARNING, ...)
end

-- Logs a message with ERROR level.
function logging:error(...)
    message(TypeLog.ERROR, ...)
end

-- Logs a message with FATAL level.
function logging:fatal(...)
    message(TypeLog.FATAL, ...)
end

function init(...)
    return logging
end

--return logging
return setmetatable(logging, { __call = function(_, ...)
    return init(...)
end })
