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
        --free_memory_tooltip:set_markup(last_result)
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

function wmapi:connect_signal(args)
    local args = args or nil

    if args == nil then
        return
    end

    local signal = args.signal or nil
    local event  = args.event or capi.event.mouse.button_click_left
    local widget = args.widget or nil
    local func   = args.func or function()
        capi.log:message("Error args.func = nil")
    end

    if widget == nil then
        return
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
        capi.log:message("name:                 " .. tostring(c.name), -- The client title.
                         "window:               " .. tostring(c.window), -- The X window id.
                         "skip_taskbar:         " .. tostring(c.skip_taskbar), -- True if the client does not want to be in taskbar.
                         "type:                 " .. tostring(c.type), -- The window type.
                         "class:                " .. tostring(c.class), -- The client class.
                         "instance:             " .. tostring(c.instance), -- The client instance.
                         "pid:                  " .. tostring(c.pid), -- The client PID, if available.
                         "role:                 " .. tostring(c.role), -- The window role, if available.
                         "machine:              " .. tostring(c.machine), -- The machine client is running on.
                         "icon_name:            " .. tostring(c.icon_name), -- The client name when iconified.
                         "icon:                 " .. tostring(c.icon), -- The client icon as a surface.
                         "icon_sizes:           " .. tostring(c.icon_sizes), -- The available sizes of client icons.
                         "screen:               " .. tostring(self:screen_id(c.screen)), -- Client screen.
                         "hidden:               " .. tostring(c.hidden), -- Define if the client must be hidden, i.e.
                         "minimized:            " .. tostring(c.minimized), -- Define it the client must be iconify, i.e.
                         "size_hints_honor:     " .. tostring(c.size_hints_honor), -- Honor size hints, e.g.
                         "border_width:         " .. tostring(c.border_width), -- The client border width.
                         "border_color:         " .. tostring(c.border_color), -- The client border color.
                         "urgent:               " .. tostring(c.urgent), -- The client urgent state.
                         "content:              " .. tostring(c.content), -- A cairo surface for the client window content.
                         "opacity:              " .. tostring(c.opacity), -- The client opacity.
                         "ontop:                " .. tostring(c.ontop), -- The client is on top of every other windows.
                         "above:                " .. tostring(c.above), -- The client is above normal windows.
                         "below:                " .. tostring(c.below), -- The client is below normal windows.
                         "fullscreen:           " .. tostring(c.fullscreen), -- The client is fullscreen or not.
                         "maximized:            " .. tostring(c.maximized), -- The client is maximized (horizontally and vertically) or not.
                         "maximized_horizontal: " .. tostring(c.maximized_horizontal), -- The client is maximized horizontally or not.
                         "maximized_vertical:   " .. tostring(c.maximized_vertical), -- The client is maximized vertically or not.
                         "transient_for:        " .. tostring(c.transient_for), -- The client the window is transient for.
                         "group_window:         " .. tostring(c.group_window), -- Window identification unique to a group of windows.
                         "leader_window:        " .. tostring(c.leader_window), -- Identification unique to windows spawned by the same command.
                         "size_hints:           " .. tostring(c.size_hints), -- A table with size hints of the client.
                         "motif_wm_hints:       " .. tostring(c.motif_wm_hints), -- The motif WM hints of the client.
                         "sticky:               " .. tostring(c.sticky), -- Set the client sticky, i.e.
                         "modal:                " .. tostring(c.modal), -- Indicate if the client is modal.
                         "focusable:            " .. tostring(c.focusable), -- True if the client can receive the input focus.
                         "shape_bounding:       " .. tostring(c.shape_bounding), -- The client’s bounding shape as set by awesome as a (native) cairo surface.
                         "shape_clip:           " .. tostring(c.shape_clip), -- The client’s clip shape as set by awesome as a (native) cairo surface.
                         "shape_input:          " .. tostring(c.shape_input), -- The client’s input shape as set by awesome as a (native) cairo surface.
                         "client_shape_bounding:" .. tostring(c.client_shape_bounding), -- The client’s bounding shape as set by the program as a (native) cairo surface.
                         "client_shape_clip:    " .. tostring(c.client_shape_clip), -- The client’s clip shape as set by the program as a (native) cairo surface.
                         "startup_id:           " .. tostring(c.startup_id), -- The FreeDesktop StartId.
                         "valid:                " .. tostring(c.valid), -- If the client that this object refers to is still managed by awesome.
                         "first_tag:            " .. tostring(c.first_tag), -- The first tag of the client.
                         "marked:               " .. tostring(c.marked), -- If a client is marked or not.
                         "is_fixed:             " .. tostring(c.is_fixed), -- Return if a client has a fixed size or not.
                         "immobilized:          " .. tostring(c.immobilized), -- Is the client immobilized horizontally?
                         "immobilized:          " .. tostring(c.immobilized), -- Is the client immobilized vertically?
                         "floating:             " .. tostring(c.floating), -- The client floating state.
                         "x:                    " .. tostring(c.x), -- The x coordinates.
                         "y:                    " .. tostring(c.y), -- The y coordinates.
                         "width:                " .. tostring(c.width), -- The width of the client.
                         "height:               " .. tostring(c.height), -- The height of the client.
                         "dockable:             " .. tostring(c.dockable), -- If the client is dockable.
                         "requests_no_titlebar: " .. tostring(c.requests_no_titlebar), -- If the client requests not to be decorated with a titlebar.
                         "shape:                " .. tostring(c.shape) -- Set the client shape.
        )

        --capi.log:message(tostring(c.size_hints.user_position),
        --                 tostring(c.size_hints.user_size),
        --                 tostring(c.size_hints.program_position),
        --                 tostring(c.size_hints.program_size),
        --                 tostring(c.size_hints.max_width),
        --                 tostring(c.size_hints.max_height),
        --                 tostring(c.size_hints.min_width),
        --                 tostring(c.size_hints.min_height),
        --                 tostring(c.size_hints.width_inc),
        --                 tostring(c.size_hints.height_inc)
        --)
    end
end

function wmapi:all_list_client()
    --for i, item in ipairs(client.get()) do
    --    self:client_info(item)
    --end

    local t = awful.screen.focused().selected_tag
    if not t then
        return
    end

    local clients = t:clients()
    capi.log:message(tostring(#clients))
end

return wmapi
