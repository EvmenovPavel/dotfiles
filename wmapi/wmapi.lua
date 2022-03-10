local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local spawn = require("awful.spawn")

local wmapi = {}

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

function wmapi:path(debug)
    local debug  = debug or debug

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

function wmapi:set_widget(...)
    if not self.res then
        self.res = wibox.widget({
                                    layout = wibox.layout.fixed.horizontal()
                                })
    end

    for i = 1, select("#", ...) do
        local item = select(i, ...)

        capi.log:message(item.type)

        if item then
            local widget = item.widget
            if widget then
                if LuaWidgetTypes[widget.type] then
                    self.res:add(widget)
                end
            else
                self.res:add(item)
            end
        end
    end

    self.widget:set_widget(self.res)
end

function wmapi:sub(stdout, length)
    return string.sub(stdout, 0, length)
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
    local primary = capi.primary or 1

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
        spawn.easy_async(command, function(stdout, stderr, exitreason, exitcode)
            callback(stdout, stderr, exitreason, exitcode)
            t:again()
        end)
    end)

    t:start()
    t:emit_signal("timeout")
end

function wmapi:easy_async_with_shell(bash)
    local last_result = ""

    awful.spawn.easy_async_with_shell(bash, function(result)
        last_result = result
        capi.log:message(tostring(last_result))
    end)

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

function wmapi:mouse_coords()
    local mouse = mouse.coords()

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

function wmapi:button(args)
    local args = args or {}

    return awful.button(
            { args.key or nil },
            args.event or capi.event.mouse.button_click_left,
            args.func or function()
                capi.log:message("Error args.func = nil")
            end
    )
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
    --capi.wmapi:connect_signal(
    --        ret.widget,
    --        capi.event.signals.button.release,
    --        capi.event.mouse.button_click_left,
    --        function()
    --            ret:set_checked(not ret.checked)
    --        end
    --)
]]

function wmapi:connect_signal(widget, signal, event, func)
    if widget == nil then
        return
    end

    local signal = signal or capi.event.signals.button.release
    local event  = event or capi.event.mouse.button_click_left
    local widget = widget or nil

    local func   = func or function()
        capi.log:message("Error args.func = nil")
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
            capi.event.signals.mouse.enter,
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
            capi.event.signals.mouse.leave,
            function(self, _, _, button)
                self.bg = "#ffffff00"
                if self.old_wibox then
                    self.old_wibox.cursor = self.old_cursor
                    self.old_wibox        = nil
                end
            end
    )

    widget:connect_signal(
            capi.event.signals.button.press,
            function(self, _, _, button)
                self.bg = "#ffffff22"
            end
    )

    widget:connect_signal(
            capi.event.signals.button.release,
            function(self, _, _, button)
                self.bg = "#ffffff11"
            end
    )

    return widget
end

function wmapi:client_info(c)
    if c then
        capi.log:message(c.name,
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
