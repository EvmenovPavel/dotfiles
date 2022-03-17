local cairo                        = require("lgi").cairo
local mouse                        = mouse
local screen                       = screen
local wibox                        = require("wibox")
local table                        = table
local keygrabber                   = keygrabber
local math                         = require("math")
local awful                        = require("awful")
local gears                        = require("gears")
local timer                        = gears.timer
local client                       = client
awful.client                       = require("awful.client")

local string                       = string
local debug                        = debug
local pairs                        = pairs
local unpack                       = unpack or table.unpack

local surface                      = cairo.ImageSurface(cairo.Format.RGB24, 20, 20)
local cr                           = cairo.Context(surface)

local resources                    = require("resources")

local languish                     = {}

-- settings

languish.settings                  = {
    preview_box                        = true,
    preview_box_bg                     = "#ddddddaa",
    preview_box_border                 = "#22222200",
    preview_box_fps                    = 30,
    preview_box_delay                  = 150,
    preview_box_title_font             = { "sans", "italic", "normal" },
    preview_box_title_font_size_factor = 0.8,
    preview_box_title_color            = { 0, 0, 0, 1 },

    client_opacity                     = false,
    client_opacity_value_selected      = 1,
    client_opacity_value_in_focus      = 0.5,
    client_opacity_value               = 0.5,

    cycle_raise_client                 = true,

    client_focus_mouse                 = true,
}

-- Create a wibox to contain all the client-widgets
languish.preview_wbox              = wibox({ width = screen[mouse.screen].geometry.width })
languish.preview_wbox.border_width = 3
languish.preview_wbox.ontop        = true
languish.preview_wbox.visible      = false

languish.preview_live_timer        = timer({ timeout = 1 / languish.settings.preview_box_fps })
languish.preview_widgets           = {}

languish.altTabTable               = {}
languish.altTabIndex               = 1

--switcher.source                    = string.sub(debug.getinfo(1, "S").source, 2)
--switcher.path                      = string.sub(switcher.source, 1, string.find(switcher.source, "/[^/]*$"))
languish.path                      = wmapi:path(debug.getinfo(1))
languish.noicon                    = languish.path .. "noicon.png"

-- simple function for counting the size of a table
function languish:tableLength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

-- this function returns the list of clients to be shown.
function languish:getClients()
    local clients  = {}

    -- Get focus history for current tag
    local m_screen = mouse.screen;
    local idx      = 0
    local c        = awful.client.focus.history.get(m_screen, idx)

    while c do
        table.insert(clients, c)

        idx = idx + 1
        c   = awful.client.focus.history.get(m_screen, idx)
    end

    -- Minimized clients will not appear in the focus history
    -- Find them by cycling through all clients, and adding them to the list
    -- if not already there.
    -- This will preserve the history AND enable you to focus on minimized clients

    local t   = m_screen.selected_tag
    local all = client.get(m_screen)

    for i = 1, #all do
        local c            = all[i]
        local ctags        = c:tags();

        -- check if the client is on the current tag
        local isCurrentTag = false
        for j = 1, #ctags do
            if t == ctags[j] then
                isCurrentTag = true
                break
            end
        end

        if isCurrentTag then
            -- check if client is already in the history
            -- if not, add it
            local addToTable = true
            for k = 1, #clients do
                if clients[k] == c then
                    addToTable = false
                    break
                end
            end

            if addToTable then
                table.insert(clients, c)
            end
        end
    end

    return clients
end

-- here we populate altTabTable using the list of clients taken from
-- _M.getClients(). In case we have altTabTable with some value, the list of the
-- old known clients is restored.
function languish:populateAltTabTable()
    local clients = self:getClients()

    if self:tableLength(languish.altTabTable) then
        for ci = 1, #clients do
            for ti = 1, #languish.altTabTable do
                if languish.altTabTable[ti].client == clients[ci] then
                    languish.altTabTable[ti].client.opacity   = languish.altTabTable[ti].opacity
                    languish.altTabTable[ti].client.minimized = languish.altTabTable[ti].minimized
                    break
                end
            end
        end
    end

    languish.altTabTable = {}

    for i = 1, #clients do
        table.insert(languish.altTabTable, {
            client    = clients[i],
            minimized = clients[i].minimized,
            opacity   = clients[i].opacity
        })
    end
end

-- If the length of list of clients is not equal to the length of altTabTable,
-- we need to repopulate the array and update the UI. This function does this
-- check.
function languish:clientsHaveChanged()
    local clients = self:getClients()
    return self:tableLength(clients) ~= self:tableLength(languish.altTabTable)
end

function languish:createPreviewText(c)
    if c.class then
        return " - " .. c.class
    else
        return " - " .. c.name
    end
end

-- Preview is created here.
function languish:clientOpacity()
    if not languish.settings.client_opacity then
        return
    end

    local opacity = languish.settings.client_opacity_value
    if opacity > 1 then
        opacity = 1
    end
    for i, data in pairs(languish.altTabTable) do
        data.client.opacity = opacity
    end

    if client.focus == languish.altTabTable[languish.altTabIndex].client then
        -- Let"s normalize the value up to 1.
        local opacityFocusSelected = languish.settings.client_opacity_value_selected + languish.settings.client_opacity_value_in_focus
        if opacityFocusSelected > 1 then
            opacityFocusSelected = 1
        end
        client.focus.opacity = opacityFocusSelected
    else
        -- Let"s normalize the value up to 1.
        local opacityFocus = languish.settings.client_opacity_value_in_focus
        if opacityFocus > 1 then
            opacityFocus = 1
        end
        local opacitySelected = languish.settings.client_opacity_value_selected
        if opacitySelected > 1 then
            opacitySelected = 1
        end

        client.focus.opacity                                      = opacityFocus
        languish.altTabTable[languish.altTabIndex].client.opacity = opacitySelected
    end
end

-- This is called any _M.settings.preview_box_fps milliseconds. In case the list
-- of clients is changed, we need to redraw the whole preview box. Otherwise, a
-- simple widget::updated signal is enough
function languish:updatePreview()
    if self:clientsHaveChanged() then
        self:populateAltTabTable()
        self:preview()
    end

    for i = 1, #languish.preview_widgets do
        languish.preview_widgets[i]:emit_signal("widget::updated")
    end
end

function languish:cycle(dir)
    -- Switch to next client
    languish.altTabIndex = languish.altTabIndex + dir
    if languish.altTabIndex > #languish.altTabTable then
        languish.altTabIndex = 1 -- wrap around
    elseif languish.altTabIndex < 1 then
        languish.altTabIndex = #languish.altTabTable -- wrap around
    end

    self:updatePreview()

    languish.altTabTable[languish.altTabIndex].client.minimized = false

    if not languish.settings.preview_box and not languish.settings.client_opacity then
        client.focus = languish.altTabTable[languish.altTabIndex].client
    end

    if languish.settings.client_opacity and languish.preview_wbox.visible then
        self:clientOpacity()
    end

    if languish.settings.cycle_raise_client == true then
        languish.altTabTable[languish.altTabIndex].client:raise()
    end
end

function languish:preview()
    if not languish.settings.preview_box then
        return
    end

    -- Apply settings
    languish.preview_wbox:set_bg(languish.settings.preview_box_bg)
    languish.preview_wbox.border_color = languish.settings.preview_box_border

    -- Make the wibox the right size, based on the number of clients
    local n                            = math.max(7, #languish.altTabTable)
    local W                            = screen[mouse.screen].geometry.width -- + 2 * _M.preview_wbox.border_width
    local w                            = W / n -- widget width
    local h                            = w * 0.75  -- widget height
    local textboxHeight                = w * 0.125

    local x                            = screen[mouse.screen].geometry.x - languish.preview_wbox.border_width
    local y                            = screen[mouse.screen].geometry.y + (screen[mouse.screen].geometry.height - h - textboxHeight) / 2
    languish.preview_wbox:geometry({ x = x, y = y, width = W, height = h + textboxHeight })

    -- create a list that holds the clients to preview, from left to right
    local leftRightTab              = {}
    local leftRightTabToAltTabIndex = {} -- save mapping from leftRightTab to altTabTable as well
    local nLeft
    local nRight
    if #languish.altTabTable == 2 then
        nLeft  = 0
        nRight = 2
    else
        nLeft  = math.floor(#languish.altTabTable / 2)
        nRight = math.ceil(#languish.altTabTable / 2)
    end

    for i = 1, nLeft do
        table.insert(leftRightTab, languish.altTabTable[#languish.altTabTable - nLeft + i].client)
        table.insert(leftRightTabToAltTabIndex, #languish.altTabTable - nLeft + i)
    end
    for i = 1, nRight do
        table.insert(leftRightTab, languish.altTabTable[i].client)
        table.insert(leftRightTabToAltTabIndex, i)
    end

    -- determine fontsize -> find maximum classname-length
    local text, textWidth, textHeight, maxText
    local maxTextWidth  = 0
    local maxTextHeight = 0
    local bigFont       = textboxHeight / 2

    --cr:set_font_size(fontSize)

    for i = 1, #leftRightTab do
        text       = self:createPreviewText(leftRightTab[i])
        textWidth  = cr:text_extents(text).width
        textHeight = cr:text_extents(text).height
        if textWidth > maxTextWidth or textHeight > maxTextHeight then
            maxTextHeight = textHeight
            maxTextWidth  = textWidth
            maxText       = text
        end
    end

    while true do
        cr:set_font_size(bigFont)
        textWidth  = cr:text_extents(maxText).width
        textHeight = cr:text_extents(maxText).height

        if textWidth < w - textboxHeight and textHeight < textboxHeight then
            break
        end

        bigFont = bigFont - 1
    end
    local smallFont          = bigFont * languish.settings.preview_box_title_font_size_factor

    languish.preview_widgets = {}

    -- create all the widgets
    for i = 1, #leftRightTab do
        languish.preview_widgets[i]      = wibox.widget.base.make_widget()
        languish.preview_widgets[i].fit  = function(preview_widget, width, height)
            return w, h
        end
        local c                          = leftRightTab[i]
        languish.preview_widgets[i].draw = function(preview_widget, preview_wbox, cr, width, height)
            if width ~= 0 and height ~= 0 then

                local a        = 0.8
                local overlay  = 0.6
                local fontSize = smallFont
                if c == languish.altTabTable[languish.altTabIndex].client then
                    a        = 0.9
                    overlay  = 0
                    fontSize = bigFont
                end

                local sx, sy, tx, ty

                -- Icons
                local icon
                if c.icon == nil then
                    icon = gears.surface(gears.surface.load(languish.noicon))
                else
                    icon = gears.surface(c.icon)
                end

                local iconboxWidth  = 0.9 * textboxHeight
                local iconboxHeight = iconboxWidth

                -- Titles
                cr:select_font_face(unpack(languish.settings.preview_box_title_font))
                cr:set_font_face(cr:get_font_face())
                cr:set_font_size(fontSize)

                text                 = self:createPreviewText(c)
                textWidth            = cr:text_extents(text).width
                textHeight           = cr:text_extents(text).height

                local titleboxWidth  = textWidth + iconboxWidth
                local titleboxHeight = textboxHeight

                -- Draw icons
                tx                   = (w - titleboxWidth) / 2
                ty                   = h
                sx                   = iconboxWidth / icon.width
                sy                   = iconboxHeight / icon.height

                cr:translate(tx, ty)
                cr:scale(sx, sy)
                cr:set_source_surface(icon, 0, 0)
                cr:paint()
                cr:scale(1 / sx, 1 / sy)
                cr:translate(-tx, -ty)

                -- Draw titles
                tx = tx + iconboxWidth
                ty = h + (textboxHeight + textHeight) / 2

                cr:set_source_rgba(unpack(languish.settings.preview_box_title_color))
                cr:move_to(tx, ty)
                cr:show_text(text)
                cr:stroke()

                -- Draw previews
                local cg = c:geometry()
                if cg.width > cg.height then
                    sx = a * w / cg.width
                    sy = math.min(sx, a * h / cg.height)
                else
                    sy = a * h / cg.height
                    sx = math.min(sy, a * h / cg.width)
                end

                tx        = (w - sx * cg.width) / 2
                ty        = (h - sy * cg.height) / 2

                local tmp = gears.surface(c.content)
                cr:translate(tx, ty)
                cr:scale(sx, sy)
                cr:set_source_surface(tmp, 0, 0)
                cr:paint()
                tmp:finish()

                -- Overlays
                cr:scale(1 / sx, 1 / sy)
                cr:translate(-tx, -ty)
                cr:set_source_rgba(0, 0, 0, overlay)
                cr:rectangle(tx, ty, sx * cg.width, sy * cg.height)
                cr:fill()
            end
        end

        -- Add mouse handler
        if languish.settings.client_focus_mouse then
            languish.preview_widgets[i]:connect_signal("mouse::enter", function()
                self:cycle(leftRightTabToAltTabIndex[i] - languish.altTabIndex)
            end)
        end
    end

    -- Spacers left and right
    local spacer         = wibox.widget.base.make_widget()
    spacer.fit           = function(leftSpacer, width, height)
        return (W - w * #languish.altTabTable) / 2, languish.preview_wbox.height
    end
    spacer.draw          = function(preview_widget, preview_wbox, cr, width, height)
    end

    --layout
    local preview_layout = wibox.layout.fixed.horizontal()

    preview_layout:add(spacer)
    for i = 1, #leftRightTab do
        preview_layout:add(languish.preview_widgets[i])
    end
    preview_layout:add(spacer)

    languish.preview_wbox:set_widget(preview_layout)
end

-- This starts the timer for updating and it shows the preview UI.
function languish:showPreview()
    languish.preview_live_timer.timeout = 1 / languish.settings.preview_box_fps
    languish.preview_live_timer:connect_signal("timeout", languish.updatePreview)
    languish.preview_live_timer:start()

    self:preview()
    languish.preview_wbox.visible = true

    self:clientOpacity()
end

function languish:close()
    if languish.preview_wbox.visible == true then
        languish.preview_wbox.visible = false
        languish.preview_live_timer:stop()
    else
        languish.previewDelayTimer:stop()
    end

    --for i = 1, #_M.altTabTable do
    --    _M.altTabTable[i].client.opacity   = _M.altTabTable[i].opacity
    --    _M.altTabTable[i].client.minimized = _M.altTabTable[i].minimized
    --end

    -- Raise clients in order to restore history
    local c
    for i = 1, languish.altTabIndex - 1 do
        c = languish.altTabTable[languish.altTabIndex - i].client
        if not languish.altTabTable[i].minimized then
            c:raise()
            client.focus = c
        end
    end

    -- raise chosen client on top of all
    c = languish.altTabTable[languish.altTabIndex].client

    if c then
        c:raise()
        client.focus = c
    end

    -- restore minimized clients
    for i = 1, #languish.altTabTable do
        if i ~= languish.altTabIndex and languish.altTabTable[i].minimized then
            languish.altTabTable[i].client.minimized = true
        end
        languish.altTabTable[i].client.opacity = languish.altTabTable[i].opacity
    end

    keygrabber.stop()
end

local function init(mod_key, key_switch)
    self:populateAltTabTable()

    if #languish.altTabTable == 0 then
        return
    elseif #languish.altTabTable == 1 then
        languish.altTabTable[1].client.minimized = false
        languish.altTabTable[1].client:raise()
        return
    end

    -- reset index
    languish.altTabIndex       = 1

    -- preview delay timer
    local previewDelay         = languish.settings.preview_box_delay / 1000
    languish.previewDelayTimer = timer({ timeout = previewDelay })
    languish.previewDelayTimer:connect_signal("timeout", function()
        languish.previewDelayTimer:stop()
        self:showPreview()
    end)
    languish.previewDelayTimer:start()

    -- Now that we have collected all windows, we should run a keygrabber
    -- as long as the user is alt-tabbing:
    keygrabber.run(
            function(mod, keys, event)
                if keys == key_switch and event == "press" then
                    self:cycle(1)
                elseif keys == mod_key and event == "release" then
                    self:close()
                end
            end
    )

    -- switch to next client
    self:cycle(1)

end -- function altTab

return setmetatable(languish, { __call = function(_, ...)
    return init(...)
end })
