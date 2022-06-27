local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local lfs   = require("lfs")

local capi  = {
    mouse = mouse
}

local posix = require("posix")
local pid   = posix.getpid("pid")

--local spawn = require("awful.spawn")

local wmapi = {}

function wmapi:widget()
    return require("lib.widget.widget")
end

function wmapi:layout_align_horizontal(items)
    --local widget = wibox.widget({
    --                                layout = wibox.layout.align.horizontal
    --                            })

    local bg     = wibox.container.background()

    local widget = wibox.layout.align.horizontal()

    for i, item in ipairs(items) do
        --widget:add(item)
        --table.insert(widget, item)
    end

    bg.widget = widget

    return bg
end

function wmapi:get_pid()
    return pid
end

local debug_ = debug

function wmapi:path(debug)
    local debug  = debug or debug_

    local source = string.sub(debug.source, 2)
    local path   = string.sub(source, 1, string.find(source, "/[^/]*$"))

    return path
end

--- Check if a file or directory exists in this path
function wmapi:exists(file)
    local ok, err, code = os.rename(file, file)

    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end

    return ok, err
end

--- Check if a directory exists in this path
function wmapi:isdir(path)
    -- "/" works on both Unix and Windows
    return self:exists(path .. "/")
end

function wmapi:table_length(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end

    return count
end

function wmapi:is_empty(s)
    return s == nil or s == ""
end

function wmapi:signs(stdout, signs)
    local signs = signs or ""
    local str   = stdout:gsub("%s+", signs)
    str         = string.gsub(str, "%s+", signs)

    return str
end

--function wmapi:set_widget(...)
--    if not self.res then
--        self.res = wibox.widget({
--                                    layout = wibox.layout.fixed.horizontal()
--                                })
--    end
--
--    for i = 1, select("#", ...) do
--        local item = select(i, ...)
--
--        log:debug(item.type)
--
--        if item then
--            local widget = item.widget
--            if widget then
--                if WidgetType[widget.type] then
--                    self.res:add(widget)
--                end
--            else
--                self.res:add(item)
--            end
--        end
--    end
--
--    self.widget:set_widget(self.res)
--end

function wmapi:remove_space(str, symbol)
    local str    = str
    local symbol = symbol or " "
    local index  = 0

    for i = 1, #str do
        local c = str:sub(i, i)
        if (c == symbol) then
        else
            index = i
            break
        end
    end

    str = str:sub(index, #str)

    for i = #str, 1, -1 do
        local c = str:sub(i, i)
        if (c == symbol) then
        else
            index = i
            break
        end
    end

    str = str:sub(1, index)

    return str
end

function wmapi:find(cmd, str)
    local cmd = "echo \"" .. cmd .. "\" | sed -rn \"s/.*" .. str .. ":\\s+([^ ]+).*/\\1/p\""

    local f   = assert(io.popen(cmd, 'r'))
    local s   = assert(f:read('*a'))
    f:close()

    s = string.gsub(s, "^%s+", "")
    s = string.gsub(s, "%s+$", "")
    s = string.gsub(s, "[\n\r]+", " ")

    return s
end

function wmapi:is_screen_primary(s)
    local primary = self:screen_primary_id()

    if s == screen[primary] then
        return true
    end

    return false
end

function wmapi:screen_primary_id()
    local primary = 1

    if screen[primary] == nil then
        return 1
    end

    return primary
end

function wmapi:screen_primary()
    local primary = self:screen_primary_id()

    return screen[primary]
end

function wmapi:screen(index)
    local index = index or self:screen_primary_id()
    local count = screen.count()

    if index > count or index < -1 then
        return screen[self:screen_primary_id()]
    end

    return screen[index]
end

function wmapi:traceback()
    log:debug("test")
end

local clock = os.clock

function wmapi:sleep(sec)
    --local t = os.clock()
    --while os.clock() - t <= n do
    -- nothing
    --end

    --local ntime = os.time() + sec
    --repeat until os.time() > ntime

    --local ntime = os.clock() + sec / 10
    --repeat until os.clock() > ntime

    local t0 = clock()
    while clock() - t0 <= sec do
    end

    --socket.sleep(sec)
    --lsocket.select(sec)

    --sleep(0.2)

    --posix.sleep(n)
end

function wmapi:is_dir(path)
    -- true - error
    return not (path:sub(-1) == "/" or lfs.attributes(path, "mode") == "directory")
end

function wmapi:is_file(path)
    -- true - error
    return not (path:sub(-1) == "/" or lfs.attributes(path, "mode") == "file")
end

function wmapi:is_attributes(path, attributes)
    -- true - error
    return not (path:sub(-1) == "/" or lfs.attributes(path, "mode") == attributes)
end

function wmapi:mkdir(name)
    lfs.mkdir(name)
end

function wmapi:file_size(file)
    local filesize = lfs.attributes(file, "size")
    -- если filesize nil = размер файла 0
    return filesize or 0
end

function wmapi:read_file(path)
    local path = string.gsub(path, "//", "/")

    if (self:is_file(path)) then
        return nil
    end

    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then
        return nil
    end

    local content = file:read("*a")
    -- *a or *all reads the whole file
    file:close()

    return content
end

function wmapi:screen_er(index)
    local index = index or 0
    local count = screen.count()

    if index > count or index <= 0 then
        return nil
    end

    return screen[index]
end

function wmapi:screen_id(s)
    for i = 1, screen.count() do
        if s == screen[i] then
            return i
        end
    end

    return 1
end

function wmapi:watch(command, timeout, callback)
    timeout = timeout or 5

    local t = gears.timer { timeout = timeout }
    t:connect_signal("timeout", function()
        t:stop()
        awful.spawn.easy_async(command, function(stdout, stderr, exitreason, exitcode)
            callback(stdout, stderr, exitreason, exitcode)
            t:again()
        end)
    end)

    t:start()
    t:emit_signal("timeout")
end

function wmapi:easy_async_with_shell(bash)
    local last_result = nil

    awful.spawn.easy_async_with_shell(bash, function(result)
        last_result = result
        log:debug("1 easy_async_with_shell: " .. tostring(last_result))
    end)

    log:debug("2 easy_async_with_shell: " .. tostring(last_result))
    return last_result
end

function wmapi:update(callback, timeout)
    local callback = callback or nil
    local timeout  = timeout or 0.3

    if callback then
        return gears.timer {
            timeout   = timeout,
            call_now  = true,
            autostart = true,
            callback  = callback
        }
    end

    return nil
end

function wmapi:int2float(integer)
    return integer + 0.0
end

function wmapi:mouse_coords()
    local mouse = capi.mouse.coords()

    return {
        x = mouse.x,
        y = mouse.y
    }
end

function wmapi:screen_geometry(index)
    local index    = index or self:screen_primary_id()
    local screen   = screen[index]
    local geometry = screen.geometry

    return {
        width  = geometry.width,
        height = geometry.height
    }
end

function wmapi:screen_height(index)
    local index = index or self:screen_primary_id()
    local s     = screen[index]

    return s.geometry.height
end

function wmapi:screen_width(index)
    local index = index or self:screen_primary_id()
    local s     = screen[index]

    return s.geometry.width
end

function wmapi:set_widget(widget, ...)
    local res = wibox.widget({
                                 layout = wibox.layout.fixed.horizontal()
                             })

    for i = 1, select("#", ...) do
        local w = select(i, ...)
        if w then
            res:add(w)
        end
    end

    widget:set_widget(res)
end

-- сигнал для виджета
-- когда подводишь мышкой к виджету
-- и начинаешь скролить, то, срабатывает евент

--[[
    --wmapi:connect_signal(
    --        ret.widget,
    --       event.signals.button.release,
    --        mouse.button_click_left,
    --        function()
    --            ret:set_checked(not ret.checked)
    --        end
    --)
]]

function wmapi:connect_signal(widget, signal, event, func)
    if widget == nil then
        return
    end

    local signal = signal or event.signals.button.release
    local event  = event or event.mouse.button_click_left

    local func   = func or function()
        log:debug("Error args.func = nil")
    end

    widget:connect_signal(
            signal,
            function(_, _, _, button)
                if button == event then
                    func()
                end
            end
    )

end

function wmapi:container(widget)
    local widget = wibox.widget {
        widget,
        widget = wibox.container.background
    }

    widget:connect_signal(
            event.signals.mouse.enter,
            function(self, _, _, button)
                self.bg = "#ffffff11"
                local w = _G.mouse.current_wibox
                if w then
                    self.old_cursor, self.old_wibox = w.cursor, w
                    w.cursor                        = "hand1"
                end
            end
    )

    widget:connect_signal(
            event.signals.mouse.leave,
            function(self, _, _, button)
                self.bg = "#ffffff00"
                if self.old_wibox then
                    self.old_wibox.cursor = self.old_cursor
                    self.old_wibox        = nil
                end
            end
    )

    widget:connect_signal(
            event.signals.button.press,
            function(self, _, _, button)
                self.bg = "#ffffff22"
            end
    )

    widget:connect_signal(
            event.signals.button.release,
            function(self, _, _, button)
                self.bg = "#ffffff11"
            end
    )

    return widget
end

function wmapi:client_info(c)
    if c then
        log:debug(c.name,
                  "tag:       " .. tostring(c.tag),
                  "tags:      " .. tostring(c.tags),
                  "instance:  " .. tostring(c.instance),
                  "class:     " .. tostring(c.class),
                  "screen:    " .. tostring(self:screen_id(c.screen)),
                  "exec_once: " .. tostring(c.exec_once),
                  "icon:      " .. tostring(c.icon),
                  "width:     " .. tostring(c.width),
                  "height:    " .. tostring(c.height)
        )
    end
end

function wmapi:list_client()
    for i, item in ipairs(client.get()) do
        self:client_info(item)
    end
end

return wmapi
