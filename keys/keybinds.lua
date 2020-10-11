local awful     = require("awful")
local gears     = require("gears")
local beautiful = require("beautiful")
local dpi       = beautiful.xresources.apply_dpi
local key       = require("event").key
local hotkeys   = require("keys.hotkeys")

local keys      = {}

keys.globalkeys = require("keys.globalkeys")
keys.clientkeys = require("keys.clientkeys")
keys.buttonkeys = require("keys.buttonkeys")

function keys:move_client(c, direction)
    if c.floating or (awful.layout.get(capi.mouse.screen) == awful.layout.suit.floating) then
        local workarea = awful.screen.focused().workarea
        if direction == "up" then
            c:geometry({ nil, y = workarea.y + beautiful.useless_gap * 2, nil, nil })
        elseif direction == "down" then
            c:geometry({ nil, y = workarea.height + workarea.y - c:geometry().height - beautiful.useless_gap * 2 - beautiful.border_width * 2, nil, nil })
        elseif direction == "left" then
            c:geometry({ x = workarea.x + beautiful.useless_gap * 2, nil, nil, nil })
        elseif direction == "right" then
            c:geometry({ x = workarea.width + workarea.x - c:geometry().width - beautiful.useless_gap * 2 - beautiful.border_width * 2, nil, nil, nil })
        end
    elseif awful.layout.get(capi.mouse.screen) == awful.layout.suit.max then
        if direction == "up" or direction == "left" then
            awful.client.swap.byidx(-1, c)
        elseif direction == "down" or direction == "right" then
            awful.client.swap.byidx(1, c)
        end
    else
        awful.client.swap.bydirection(direction, c, nil)
    end
end

local floating_resize_amount = dpi(20)
local tiling_resize_factor   = 0.05

function keys:resize_client(c, direction)
    if awful.layout.get(capi.mouse.screen) == awful.layout.suit.floating or (c and c.floating) then
        if direction == "up" then
            c:relative_move(0, 0, 0, -floating_resize_amount)
        elseif direction == "down" then
            c:relative_move(0, 0, 0, floating_resize_amount)
        elseif direction == "left" then
            c:relative_move(0, 0, -floating_resize_amount, 0)
        elseif direction == "right" then
            c:relative_move(0, 0, floating_resize_amount, 0)
        end
    else
        if direction == "up" then
            awful.client.incwfact(-tiling_resize_factor)
        elseif direction == "down" then
            awful.client.incwfact(tiling_resize_factor)
        elseif direction == "left" then
            awful.tag.incmwfact(-tiling_resize_factor)
        elseif direction == "right" then
            awful.tag.incmwfact(tiling_resize_factor)
        end
    end
end

function keys:raise_client()
    if capi.client.focus then
        capi.client.focus:raise()
    end
end

for i = 1, 9 do
    local descr_view, descr_toggle, descr_move, descr_toggle_focus
    if i == 1 or i == ipairs(capi.root.tags()) then
        descr_view         = hotkeys.tag.view
        descr_toggle       = hotkeys.tag.toggle
        descr_move         = hotkeys.tag.move
        descr_toggle_focus = hotkeys.tag.toggle_focused
    end

    keys.globalkeys = gears.table.join(keys.globalkeys,
                                       awful.key({ key.mod }, i,
                                                 function()
                                                     local screen = awful.screen.focused()
                                                     local tag    = screen.tags[i]
                                                     if tag then
                                                         tag:view_only()
                                                     end
                                                 end,
                                                 descr_view),

                                       awful.key({ key.mod, key.shift }, i,
                                                 function()
                                                     if capi.client.focus then
                                                         local tag = capi.client.focus.screen.tags[i]
                                                         if tag then
                                                             capi.client.focus:move_to_tag(tag)

                                                             local screen  = awful.screen.focused()
                                                             local focused = screen.tags[i]
                                                             if focused then
                                                                 focused:view_only()
                                                             end
                                                         end
                                                     end
                                                 end,
                                                 descr_move),

                                       awful.key({ key.mod, key.shift }, key.ctrl, i,
                                                 function()
                                                     if capi.client.focus then
                                                         --local tag = capi.client.focus.screen.tags[i]
                                                         local tag = capi.screen[2].tags[9]
                                                         if tag then
                                                             capi.client.screen.focus:move_to_tag(tag)

                                                             --local screen  = awful.screen.focused()
                                                             --local focused = screen.tags[i]
                                                             --if focused then
                                                             --    focused:view_only()
                                                             --end
                                                         end
                                                     end
                                                 end,
                                                 descr_move)
    )
end

return keys