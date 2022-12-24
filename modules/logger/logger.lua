local log_level       = {
    LOG_LEVEL_DEBUG    = "DEBUG", -- /* normal debugging level */
    LOG_LEVEL_INFO     = "INFO", -- /* chatty status but not debug */
    LOG_LEVEL_WARNING  = "WARNING", -- /* can be set to fatal */
    LOG_LEVEL_CRITICAL = "CRITICAL", -- /* always enabled, can be set to fatal */
    LOG_LEVEL_ERROR    = "ERROR", -- /* "error" is always fatal (aborts) */
    LOG_LEVEL_FATAL    = "FATAL",
};

local PARENT_LOG_PATH = os.getenv("HOME") .. "/.config/awesome/logs"

local logging         = {}

local setting         = {
    date_format     = "%Y-%m-%d",
    time_format     = "%H.%M.%S",
    datetime_format = "%Y-%m-%d %H.%M.%S",

    name_file       = "logging",
    type_file       = ".log",

    index           = 0
}

local private         = {
    datetime         = os.date(setting.date_format),
    filename         = nil,
    currnet_log_path = nil,
}

local function create_dirs()
    -- создаем папку logs
    if wmapi:is_dir(PARENT_LOG_PATH) then
        wmapi:mkdir(PARENT_LOG_PATH)
    end

    -- создаем под папку с нынешней датой
    private.currnet_log_path = PARENT_LOG_PATH .. "/" .. private.datetime
    if wmapi:is_dir(private.currnet_log_path) then
        wmapi:mkdir(private.currnet_log_path)
    end
end

local function update_datetime()
    private.datetime = os.date(setting.date_format)
end

local function update_filename()
    -- проверяем размер файла
    private.filename = setting.name_file .. tostring(setting.index) .. setting.type_file

    local file       = private.currnet_log_path .. "/" .. private.filename
    local filesize   = wmapi:file_size(file)

    local temp_size  = math.ceil(filesize / 1024)
    if temp_size > 60 then
        setting.index = setting.index + 1
        update_filename()
    end
end

local function write_file(type, msg)
    local pid = wmapi:get_pid()

    -- обновляем дату
    update_datetime()
    -- создаем папки
    create_dirs()
    -- обновляем имя файла
    update_filename()

    local date   = os.date(setting.datetime_format)
    local str    = string.format("%s, [%s] %s: %s\n", date, pid, type, msg)

    local file   = private.currnet_log_path .. "/" .. private.filename

    local stream = io.open(file, "a")
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
