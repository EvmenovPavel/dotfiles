local awful          = require("lib.awful")
local gtable         = require("lib.gears.table")
local widget         = require("util.widgets")
local helpers        = require("helpers")
local beautiful      = require("lib.beautiful")

-- Get theme variables
local tile_color     = beautiful.desktop_mode_color_tile or beautiful.primary
local floating_color = beautiful.desktop_mode_color_floating or beautiful.secondary
local max_color      = beautiful.desktop_mode_color_max or beautiful.alert
local floating_text  = beautiful.desktop_mode_text_floating or ""
local tile_text      = beautiful.desktop_mode_text_tile or ""
local max_text       = beautiful.desktop_mode_text_max or "类"

local layoutbox      = widget.create_button(tile_color, tile_text)
layoutbox:buttons(gtable.join(
        awful.button({}, 1, function()
            awful.layout.inc(1)
        end),
        awful.button({}, 3, function()
            awful.layout.inc(-1)
        end),
        awful.button({}, 4, function()
            awful.layout.inc(1)
        end),
        awful.button({}, 5, function()
            awful.layout.inc(-1)
        end)
))

local function update_widget()
    local current_layout = awful.layout.get(mouse.screen)
    local color, txt

    if current_layout == awful.layout.suit.max then
        color = max_color
        txt   = max_text
    elseif current_layout == awful.layout.suit.tile then
        color = tile_color
        txt   = tile_text
    elseif current_layout == awful.layout.suit.floating then
        color = floating_color
        txt   = floating_text
    else
        color = tile_color
        txt   = tile_text
    end

    layoutbox.markup = helpers.colorize_text(txt, color)
end

-- Signals
awful.tag.attached_connect_signal(s, "property::selected", function()
    update_widget()
end)
awful.tag.attached_connect_signal(s, "property::layout", function()
    update_widget()
end)

local layoutbox_widget = widget.box('horizontal', { layoutbox })
return layoutbox_widget
