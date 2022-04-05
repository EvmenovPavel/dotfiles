local log_level        = {
    LOG_LEVEL_DEBUG    = "DEBUG", -- /* normal debugging level */
    LOG_LEVEL_INFO     = "INFO", -- /* chatty status but not debug */
    LOG_LEVEL_WARNING  = "WARNING", -- /* can be set to fatal */
    LOG_LEVEL_CRITICAL = "CRITICAL", -- /* always enabled, can be set to fatal */
    LOG_LEVEL_ERROR    = "ERROR", -- /* "error" is always fatal (aborts) */
    LOG_LEVEL_FATAL    = "FATAL",
};

local logging          = {}

local date_time_format = "%Y-%m-%d %H:%M:%S"
local filename         = "logging.log"
local signal           = nil

local function write_file(type, msg)
    local path = os.getenv("HOME") .. "/.config/awesome/"
    local date = os.date(date_time_format)
    local pid  = wmapi:get_pid()
    local str  = string.format("%s, [%s] %s: %s\n", date, pid, type, msg)

    if (not signal == nil) then
        signal(msg)
    end

    local file = io.open(path .. filename, "a")
    if (file) then
        file:write(str)

        --if (signal) then
        --    signal(str)
        --end

        file:close()

        return false
    end

    return true
end

local function message(type, ...)
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
        return write_file(type, msg)
    end
end

function logging:set_format(format)
    date_time_format = format
end

function logging:set_signal(sig)
    signal = sig
end

function logging:set_file_name(name)
    filename = name
end

-- Logs a message with DEBUG level.
function logging:debug(...)
    message(log_level.LOG_LEVEL_DEBUG, ...)
end

-- Logs a message with INFO level.
function logging:info(...)
    message(log_level.LOG_LEVEL_INFO, ...)
end

-- Logs a message with WARNING level.
function logging:warning(...)
    message(log_level.LOG_LEVEL_WARNING, ...)
end

-- Logs a message with CRITICAL level.
function logging:critical(...)
    message(log_level.LOG_LEVEL_CRITICAL, ...)
end

-- Logs a message with ERROR level.
function logging:error(...)
    message(log_level.LOG_LEVEL_ERROR, ...)
end

-- Logs a message with FATAL level.
function logging:fatal(...)
    message(log_level.LOG_LEVEL_FATAL, ...)
end

local function init(...)
    return logging
end

--return logging
return setmetatable(logging, { __call = function(_, ...)
    return init(...)
end })
