local awful                        = require("lib.awful")
local wibox                        = require("lib.wibox")
local gears                        = require("lib.gears")
local beautiful                    = require("lib.beautiful")
local awful_menu                   = require("lib.awful.menu")

local wmapi                        = require("lib.wmapi")
local config                       = require("config")

local fun                          = require("functions")

awful.titlebar.enable_tooltip      = false
awful.titlebar.fallback_name       = 'Client\'s name'
beautiful.titlebar_enabled         = true
beautiful.titlebar_size            = 25
beautiful.titlebar_font            = config.title_font
beautiful.titlebar_title_align     = config.position.top
beautiful.titlebar_position        = "top"
beautiful.titlebar_imitate_borders = true

local type                         = type
local abutton                      = require("lib.awful.button")
local atooltip                     = require("lib.awful.tooltip")
local clienticon                   = require("lib.awful.widget.clienticon")

local capi                         = {
    client = client
}

local titlebar                     = {
    widget         = {},
    enable_tooltip = true,
    fallback_name  = '<unknown>'
}

local all_titlebars                = setmetatable({}, { __mode = 'k' })

function titlebar:titlewidget(c)
    local ret = wibox.widget.textbox()
    local function update()
        ret:set_text(c.name or titlebar.fallback_name)
    end

    c:connect_signal("property::name", update)
    update()

    return ret
end

function titlebar:iconwidget(c)
    return clienticon(c)
end

function titlebar:button(c, name, selector, action)
    local ret = wibox.widget.imagebox()

    if titlebar.enable_tooltip then
        ret._private.tooltip = atooltip({ objects = { ret }, delay_show = 1 })
        ret._private.tooltip:set_text(name)
    end

    local function update()
        local img = selector(c)
        if type(img) ~= "nil" then
            -- Convert booleans automatically
            if type(img) == "boolean" then
                if img then
                    img = "active"
                else
                    img = "inactive"
                end
            end
            local prefix = "normal"
            if capi.client.focus == c then
                prefix = "focus"
            end
            if img ~= "" then
                prefix = prefix .. "_"
            end
            local state = ret.state
            if state ~= "" then
                state = "_" .. state
            end

            local theme = beautiful["titlebar_" .. name .. "_button_" .. prefix .. img .. state]
                    or beautiful["titlebar_" .. name .. "_button_" .. prefix .. img]
                    or beautiful["titlebar_" .. name .. "_button_" .. img]
                    or beautiful["titlebar_" .. name .. "_button_" .. prefix .. "_inactive"]
            if theme then
                img = theme
            end
        end
        ret:set_image(img)
    end

    ret.state = ""
    if action then
        ret:buttons(abutton({}, 1, nil, function()
            ret.state = ""
            update()
            action(c, selector(c))
        end))
    else
        ret:buttons(abutton({}, 1, nil, function()
            ret.state = ""
            update()
        end))
    end
    ret:connect_signal("mouse::enter", function()
        ret.state = "hover"
        update()
    end)
    ret:connect_signal("mouse::leave", function()
        ret.state = ""
        update()
    end)
    ret:connect_signal("button::press", function(_, _, _, b)
        if b == 1 then
            ret.state = "press"
            update()
        end
    end)
    ret.update = update
    update()

    c:connect_signal("focus", update)
    c:connect_signal("unfocus", update)

    return ret
end

function titlebar:floatingbutton(c)
    local widget = titlebar:button(c, "floating",
                                   function(cl)
                                       return cl.floating
                                   end,
                                   function(cl, state)
                                       fun:on_floating(cl)
                                   end)
    return widget
end

function titlebar:maximizedbutton(c)
    local widget = titlebar:button(c, "maximized",
                                   function(cl)
                                       return cl.maximized
                                   end,
                                   function(cl, state)
                                       fun:on_maximized(cl)
                                   end)
    return widget
end

function titlebar:minimizebutton(c)
    local widget = titlebar:button(c, "minimize",
                                   function()
                                       return ""
                                   end,
                                   function(cl)
                                       fun:on_minimized(cl)
                                   end)
    return widget
end

function titlebar:closebutton(c)
    return titlebar:button(c, "close",
                           function()
                               return ""
                           end,
                           function(cl)
                               fun:on_close(cl)
                           end)
end

function titlebar:ontopbutton(c)
    local widget = titlebar:button(c, "ontop",
                                   function(cl)
                                       return cl.ontop
                                   end,
                                   function(cl, state)
                                       fun:on_ontop(cl)
                                   end)
    return widget
end

function titlebar:stickybutton(c)
    local widget = titlebar:button(c, "sticky",
                                   function(cl)
                                       return cl.sticky
                                   end,
                                   function(cl, state)
                                       fun:on_sticky(cl)
                                   end)
    return widget
end

local menu_widget = {}

function titlebar:menu(c)
    local widget = titlebar:button(c, "menu",
                                   function()
                                       return ""
                                   end,
                                   function(cl, state)
                                       menu_widget:toggle()
                                   end)

    return widget
end

function titlebar:test()

end

function titlebar:add_menu(c)
    local _menu    = awful_menu()

    local ontop    = {
        "Ontop '" .. tostring(c.ontop) .. "'",
        titlebar:test(),
        --"c.ontop",
        --resources.widgets.memory
    }

    local sticky   = {
        "Sticky '" .. tostring(c.sticky) .. "'",
        titlebar:stickybutton(c),
        --"c.sticky",
        --resources.widgets.memory
    }

    local floating = {
        "Floating '" .. tostring(c.floating) .. "'",
        titlebar:floatingbutton(c),
        --"c.floating",
        --resources.widgets.memory
    }

    _menu:add(ontop)
    _menu:add(sticky)
    _menu:add(floating)

    function menu_widget:toggle()
        --_menu:update()
        _menu:toggle()
    end

    return _menu
end

client.connect_signal("unmanage",
                      function(c)
                          all_titlebars[c] = nil
                      end)

client.connect_signal("request::titlebars",
                      function(c, startup)
                          -- Custom
                          if beautiful.titlebar_fun then
                              beautiful.titlebar_fun(c)
                              return
                          end

                          -- Enable sloppy focus
                          if config.focus then
                              c:connect_signal("mouse::enter",
                                               function(c)
                                                   if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                                                           and awful.client.focus.filter(c) then
                                                       client.focus = c
                                                   end
                                               end)
                          end

                          if not startup then
                              -- Set the windows at the slave,
                              -- i.e. put it at the end of others instead of setting it master.
                              -- awful.client.setslave(c)

                              -- Put windows in a smart way, only if they does not set an initial position.
                              if not c.size_hints.user_position and not c.size_hints.program_position then
                                  awful.placement.no_overlap(c)
                                  awful.placement.no_offscreen(c)
                              end
                          end

                          --if (c.type == "normal" or c.type == "dialog") then
                          -- buttons for the titlebar
                          local buttons     = awful.util.table.join(awful.button({}, 1,
                                                                                 function()
                                                                                     client.focus = c
                                                                                     c:raise()
                                                                                     awful.mouse.client.move(c)
                                                                                 end),
                                                                    awful.button({}, 3,
                                                                                 function()
                                                                                     if c.floating then
                                                                                         client.focus = c
                                                                                         c:raise()
                                                                                         awful.mouse.client.resize(c)
                                                                                     end
                                                                                 end))


                          -- Widgets that are aligned to the left
                          local left_layout = wibox.layout.fixed.horizontal()
                          left_layout:add(wmapi:pad(2))
                          local icon = wibox.widget {
                              {
                                  clienticon(c),
                                  layout = wibox.layout.align.horizontal
                              },
                              top    = 3,
                              left   = 3,
                              bottom = 3,
                              right  = 3,
                              widget = wibox.container.margin,
                          }
                          left_layout:add(icon)

                          --mytitlebar:add_menu(c)
                          -- Widgets that are aligned to the right
                          local right_layout = wibox.layout.fixed.horizontal()
                          --right_layout:add(mytitlebar:menu(c))
                          right_layout:add(titlebar:minimizebutton(c))
                          right_layout:add(titlebar:maximizedbutton(c))
                          right_layout:add(titlebar:closebutton(c))


                          -- The title goes in the middle
                          local middle_layout = wibox.layout.flex.horizontal()
                          local title         = awful.titlebar.widget.titlewidget(c)
                          title:set_align("center")
                          middle_layout:add(title)
                          middle_layout:buttons(buttons)


                          -- Now bring it all together
                          local layout = wibox.layout.align.horizontal()
                          layout:set_left(left_layout)
                          layout:set_right(right_layout)
                          layout:set_middle(middle_layout)

                          awful.titlebar(c, {
                              -- FIX
                              --bg       = awful.titlebar.titlebar_color or "#00ff00",
                              size     = beautiful.titlebar_size,
                              position = beautiful.titlebar_position,
                              --font     = beautiful.titlebar_font
                          })   :set_widget(layout)

                          if config.shape then
                              c.shape = function(cr, w, h)
                                  if config.borderWidth then
                                      if c.maximized or c.fullscreen then
                                          gears.shape.partially_rounded_rect(cr, w, h, false, false, false, false, 0)
                                      else
                                          gears.shape.partially_rounded_rect(cr, w, h, true, true, true, true, 10)
                                      end
                                  else
                                      gears.shape.partially_rounded_rect(cr, w, h, false, false, false, false, 0)
                                  end
                              end
                          end
                      end
)
