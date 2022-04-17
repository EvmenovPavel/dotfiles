local lfs       = require("lfs")

local log_level = {
    LOG_LEVEL_DEBUG    = "DEBUG", -- /* normal debugging level */
    LOG_LEVEL_INFO     = "INFO", -- /* chatty status but not debug */
    LOG_LEVEL_WARNING  = "WARNING", -- /* can be set to fatal */
    LOG_LEVEL_CRITICAL = "CRITICAL", -- /* always enabled, can be set to fatal */
    LOG_LEVEL_ERROR    = "ERROR", -- /* "error" is always fatal (aborts) */
    LOG_LEVEL_FATAL    = "FATAL",
};

local logging   = {}

local setting   = {
    date_format     = "%Y-%m-%d",
    time_format     = "%H.%M.%S",
    datetime_format = "%Y-%m-%d %H.%M.%S",

    name_file       = "logging",
    type_file       = ".log",

    index           = 1
}

local filename  = setting.name_file .. tostring(setting.index) .. setting.type_file
--local signal           = nil

local log_path  = os.getenv("HOME") .. "/.config/awesome/logs"

local function write_file(type, msg)
    local pid = wmapi:get_pid()

    -- создаем папку logs
    if wmapi:is_dir(log_path) then
        wmapi:mkdir(log_path)
    end

    -- создаем под папку с нынешней датой
    local temp_path = log_path .. "/" .. os.date(setting.date_format)
    if wmapi:is_dir(temp_path) then
        wmapi:mkdir(temp_path)
    end

    -- проверяем размер файла
    local temp_file_size = temp_path .. "/" .. filename
    local filesize       = lfs.attributes(temp_file_size, "size")
    -- если filesize nil = размер файла 0
    filesize             = filesize or 0

    local temp_pathfile  = temp_path .. "/" .. setting.name_file .. tostring(setting.index) .. setting.type_file
    local temp_size      = math.ceil(filesize / 1024)
    if temp_size > 60 then
        while true do
            temp_pathfile = temp_path .. "/" .. setting.name_file .. tostring(setting.index) .. setting.type_file
            if wmapi:is_file(temp_pathfile) then
                break
            else
                setting.index = setting.index + 1
            end
        end
    end

    local date   = os.date(setting.datetime_format)
    local str    = string.format("%s, [%s] %s: %s\n", date, pid, type, msg)

    local stream = io.open(temp_pathfile, "a")
    if stream then
        stream:write(str)

        stream:close()

        return false
    end

    return true
end

local function message(type, ...)
    local msg

    for i = 1, select("#", ...) do
        local item = select(i, ...)
        if msg == nil or msg == "" then
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
    -- принимает имя
    -- и сохраняем в базе, новое имя
    file = name
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
