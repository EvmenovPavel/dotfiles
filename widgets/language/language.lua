local cairo                        = require("lgi").cairo
local wibox                        = require("wibox")
local math                         = require("math")
local awful                        = require("awful")
local gears                        = require("gears")
local timer                        = gears.timer
local pairs                        = pairs
awful.client                       = require("awful.client")
local unpack                       = unpack or table.unpack

local capi                         = {
    mouse      = mouse,
    screen     = screen,
    keygrabber = keygrabber,
    client     = client,
}

local surface                      = cairo.ImageSurface(cairo.Format.RGB24, 20, 20)
local cr                           = cairo.Context(surface)

local language                     = {}

-- settings
language.settings                  = {
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
language.preview_wbox              = wibox({ width = capi.screen[capi.mouse.screen].geometry.width })
language.preview_wbox.border_width = 3
language.preview_wbox.ontop        = true
language.preview_wbox.visible      = false

language.preview_live_timer        = timer({ timeout = 1 / language.settings.preview_box_fps })
language.preview_widgets           = {}

language.altTabTable               = {}
language.altTabIndex               = 1

--switcher.source                    = string.sub(debug.getinfo(1, "S").source, 2)
--switcher.path                      = string.sub(switcher.source, 1, string.find(switcher.source, "/[^/]*$"))
language.path                      = wmapi:path(debug.getinfo(1))
language.noicon                    = language.path .. "error.png"

-- simple function for counting the size of a table
function language:tableLength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

-- this function returns the list of clients to be shown.
function language:getClients()
    local clients  = {}

    -- Get focus history for current tag
    local m_screen = capi.mouse.screen;
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
    local all = capi.client.get(m_screen)

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
function language:populateAltTabTable()
    local clients = self:getClients()

    if self:tableLength(language.altTabTable) then
        for ci = 1, #clients do
            for ti = 1, #language.altTabTable do
                if language.altTabTable[ti].client == clients[ci] then
                    language.altTabTable[ti].client.opacity   = language.altTabTable[ti].opacity
                    language.altTabTable[ti].client.minimized = language.altTabTable[ti].minimized
                    break
                end
            end
        end
    end

    language.altTabTable = {}

    for i = 1, #clients do
        table.insert(language.altTabTable, {
            client    = clients[i],
            minimized = clients[i].minimized,
            opacity   = clients[i].opacity
        })
    end
end

-- If the length of list of clients is not equal to the length of altTabTable,
-- we need to repopulate the array and update the UI. This function does this
-- check.
function language:clientsHaveChanged()
    local clients = self:getClients()
    return self:tableLength(clients) ~= self:tableLength(language.altTabTable)
end

function language:createPreviewText(c)
    if c.class then
        return " - " .. c.class
    else
        return " - " .. c.name
    end
end

-- Preview is created here.
function language:clientOpacity()
    if not language.settings.client_opacity then
        return
    end

    local opacity = language.settings.client_opacity_value
    if opacity > 1 then
        opacity = 1
    end
    for i, data in pairs(language.altTabTable) do
        data.client.opacity = opacity
    end

    if capi.client.focus == language.altTabTable[language.altTabIndex].client then
        -- Let"s normalize the value up to 1.
        local opacityFocusSelected = language.settings.client_opacity_value_selected + language.settings.client_opacity_value_in_focus
        if opacityFocusSelected > 1 then
            opacityFocusSelected = 1
        end
        capi.client.focus.opacity = opacityFocusSelected
    else
        -- Let"s normalize the value up to 1.
        local opacityFocus = language.settings.client_opacity_value_in_focus
        if opacityFocus > 1 then
            opacityFocus = 1
        end
        local opacitySelected = language.settings.client_opacity_value_selected
        if opacitySelected > 1 then
            opacitySelected = 1
        end

        capi.client.focus.opacity                                 = opacityFocus
        language.altTabTable[language.altTabIndex].client.opacity = opacitySelected
    end
end

-- This is called any _M.settings.preview_box_fps milliseconds. In case the list
-- of clients is changed, we need to redraw the whole preview box. Otherwise, a
-- simple widget::updated signal is enough
function language:updatePreview()
    if self:clientsHaveChanged() then
        self:populateAltTabTable()
        self:preview()
    end

    for i = 1, #language.preview_widgets do
        language.preview_widgets[i]:emit_signal("widget::updated")
    end
end

function language:cycle(dir)
    -- Switch to next client
    language.altTabIndex = language.altTabIndex + dir
    if language.altTabIndex > #language.altTabTable then
        language.altTabIndex = 1 -- wrap around
    elseif language.altTabIndex < 1 then
        language.altTabIndex = #language.altTabTable -- wrap around
    end

    self:updatePreview()

    language.altTabTable[language.altTabIndex].client.minimized = false

    if not language.settings.preview_box and not language.settings.client_opacity then
        capi.client.focus = language.altTabTable[language.altTabIndex].client
    end

    if language.settings.client_opacity and language.preview_wbox.visible then
        self:clientOpacity()
    end

    if language.settings.cycle_raise_client == true then
        language.altTabTable[language.altTabIndex].client:raise()
    end
end

function language:preview()
    if not language.settings.preview_box then
        return
    end

    -- Apply settings
    language.preview_wbox:set_bg(language.settings.preview_box_bg)
    language.preview_wbox.border_color = language.settings.preview_box_border

    -- Make the wibox the right size, based on the number of clients
    local n                            = math.max(7, #language.altTabTable)
    local W                            = capi.screen[capi.mouse.screen].geometry.width -- + 2 * _M.preview_wbox.border_width
    local w                            = W / n -- widget width
    local h                            = w * 0.75  -- widget height
    local textboxHeight                = w * 0.125

    local x                            = capi.screen[capi.mouse.screen].geometry.x - language.preview_wbox.border_width
    local y                            = capi.screen[capi.mouse.screen].geometry.y + (capi.screen[capi.mouse.screen].geometry.height - h - textboxHeight) / 2
    language.preview_wbox:geometry({ x = x, y = y, width = W, height = h + textboxHeight })

    -- create a list that holds the clients to preview, from left to right
    local leftRightTab              = {}
    local leftRightTabToAltTabIndex = {} -- save mapping from leftRightTab to altTabTable as well
    local nLeft
    local nRight
    if #language.altTabTable == 2 then
        nLeft  = 0
        nRight = 2
    else
        nLeft  = math.floor(#language.altTabTable / 2)
        nRight = math.ceil(#language.altTabTable / 2)
    end

    for i = 1, nLeft do
        table.insert(leftRightTab, language.altTabTable[#language.altTabTable - nLeft + i].client)
        table.insert(leftRightTabToAltTabIndex, #language.altTabTable - nLeft + i)
    end
    for i = 1, nRight do
        table.insert(leftRightTab, language.altTabTable[i].client)
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
    local smallFont          = bigFont * language.settings.preview_box_title_font_size_factor

    language.preview_widgets = {}

    -- create all the widgets
    for i = 1, #leftRightTab do
        language.preview_widgets[i]      = wibox.widget.base.make_widget()
        language.preview_widgets[i].fit  = function(preview_widget, width, height)
            return w, h
        end

        local c                          = leftRightTab[i]
        language.preview_widgets[i].draw = function(preview_widget, preview_wbox, cr, width, height)
            if width ~= 0 and height ~= 0 then

                local a        = 0.8
                local overlay  = 0.6
                local fontSize = smallFont
                if c == language.altTabTable[language.altTabIndex].client then
                    a        = 0.9
                    overlay  = 0
                    fontSize = bigFont
                end

                local sx, sy, tx, ty

                -- Icons
                local icon
                if c.icon == nil then
                    icon = gears.surface(gears.surface.load(language.noicon))
                else
                    icon = gears.surface(c.icon)
                end

                local iconboxWidth  = 0.9 * textboxHeight
                local iconboxHeight = iconboxWidth

                -- Titles
                cr:select_font_face(unpack(language.settings.preview_box_title_font))
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

                cr:set_source_rgba(unpack(language.settings.preview_box_title_color))
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
        if language.settings.client_focus_mouse then
            language.preview_widgets[i]:connect_signal("mouse::enter", function()
                self:cycle(leftRightTabToAltTabIndex[i] - language.altTabIndex)
            end)
        end
    end

    -- Spacers left and right
    local spacer         = wibox.widget.base.make_widget()
    spacer.fit           = function(leftSpacer, width, height)
        return (W - w * #language.altTabTable) / 2, language.preview_wbox.height
    end

    spacer.draw          = function(preview_widget, preview_wbox, cr, width, height)
    end

    --layout
    local preview_layout = wibox.layout.fixed.horizontal()

    preview_layout:add(spacer)
    for i = 1, #leftRightTab do
        preview_layout:add(language.preview_widgets[i])
    end
    preview_layout:add(spacer)

    language.preview_wbox:set_widget(preview_layout)
end

-- This starts the timer for updating and it shows the preview UI.
function language:showPreview()
    language.preview_live_timer.timeout = 1 / language.settings.preview_box_fps
    language.preview_live_timer:connect_signal("timeout", language.updatePreview)
    language.preview_live_timer:start()

    self:preview()
    language.preview_wbox.visible = true

    self:clientOpacity()
end

function language:close()
    if language.preview_wbox.visible == true then
        language.preview_wbox.visible = false
        language.preview_live_timer:stop()
    else
        language.previewDelayTimer:stop()
    end

    --for i = 1, #_M.altTabTable do
    --    _M.altTabTable[i].client.opacity   = _M.altTabTable[i].opacity
    --    _M.altTabTable[i].client.minimized = _M.altTabTable[i].minimized
    --end

    -- Raise clients in order to restore history
    local c
    for i = 1, language.altTabIndex - 1 do
        c = language.altTabTable[language.altTabIndex - i].client
        if not language.altTabTable[i].minimized then
            c:raise()
            capi.client.focus = c
        end
    end

    -- raise chosen client on top of all
    c = language.altTabTable[language.altTabIndex].client

    if c then
        c:raise()
        capi.client.focus = c
    else
        return
    end

    -- restore minimized clients
    for i = 1, #language.altTabTable do
        if i ~= language.altTabIndex and language.altTabTable[i].minimized then
            language.altTabTable[i].client.minimized = true
        end
        language.altTabTable[i].client.opacity = language.altTabTable[i].opacity
    end

    capi.keygrabber.stop()
end

function language:init(mod_key, key_switch)
    language:populateAltTabTable()

    if #language.altTabTable == 0 then
        return
    elseif #language.altTabTable == 1 then
        language.altTabTable[1].client.minimized = false
        language.altTabTable[1].client:raise()
        return
    end

    -- reset index
    language.altTabIndex       = 1

    -- preview delay timer
    local previewDelay         = language.settings.preview_box_delay / 1000
    language.previewDelayTimer = timer({ timeout = previewDelay })
    language.previewDelayTimer:connect_signal("timeout", function()
        language.previewDelayTimer:stop()
        language:showPreview()
    end)
    language.previewDelayTimer:start()

    -- Now that we have collected all windows, we should run a keygrabber
    -- as long as the user is alt-tabbing:
    capi.keygrabber.run(
            function(mod, keys, event)
                if keys == key_switch and event == "press" then
                    language:cycle(1)
                elseif keys == mod_key and event == "release" then
                    language:close()
                end
            end
    )

    -- switch to next client
    language:cycle(1)

end -- function altTab

return setmetatable(language, { __call = function(_, ...)
    return language:init(...)
end })
