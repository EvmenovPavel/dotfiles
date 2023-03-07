local awful                   = require("awful")
local wibox                   = require("wibox")
local beautiful               = require("beautiful")

awful.titlebar.enable_tooltip = false
awful.titlebar.fallback_name  = 'Client\'s name'

local type                    = type
local abutton                 = require("awful.button")
local atooltip                = require("awful.tooltip")
local clienticon              = require("awful.widget.clienticon")

local mytitlebar              = {
    widget         = {},
    enable_tooltip = true,
    fallback_name  = '<unknown>'
}

local all_titlebars           = setmetatable({}, { __mode = 'k' })

function mytitlebar:titlewidget(c)
    local ret = wibox.widget.textbox()
    local function update()
        ret:set_text(c.name or mytitlebar.fallback_name)
    end

    c:connect_signal("property::name", update)
    update()

    return ret
end

function mytitlebar:button(c, name, selector, action)
    local imagebox = wibox.widget.imagebox()

    if mytitlebar.enable_tooltip then
        imagebox._private.tooltip = atooltip({ objects = { imagebox }, delay_show = 1 })
        imagebox._private.tooltip:set_text(name)
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
            if client.focus == c then
                prefix = "focus"
            end

            if img ~= "" then
                prefix = prefix .. "_"
            end

            local state = imagebox.state
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

        imagebox:set_image(img)
    end

    imagebox.state = ""

    if action then
        imagebox:buttons(abutton({}, 1, nil, function()
            imagebox.state = ""
            update()
            action(c, selector(c))
        end))
    else
        imagebox:buttons(abutton({}, 1, nil, function()
            imagebox.state = ""
            update()
        end))
    end

    imagebox:connect_signal("mouse::enter", function()
        imagebox.state = "hover"
        update()
    end)

    imagebox:connect_signal("mouse::leave", function()
        imagebox.state = ""
        update()
    end)

    imagebox:connect_signal("button::press", function(_, _, _, b)
        if b == 1 then
            imagebox.state = "press"
            update()
        end
    end)

    imagebox.update = update
    update()

    c:connect_signal("focus", update)
    c:connect_signal("unfocus", update)

    return imagebox
end

function mytitlebar:floatingbutton(c)
    local widget = mytitlebar:button(c, "floating",
                                     function(cl)
                                     end,
                                     function(cl)
                                         wmapi:on_floating(cl)
                                     end)
    c:connect_signal("property::floating", widget.update)
    return widget
end

function mytitlebar:maximizedbutton(c)
    local widget = mytitlebar:button(c, "maximized",
                                     function(cl)
                                         return cl.maximized
                                     end,
                                     function(cl, state)
                                         wmapi:on_maximized(cl, state)
                                     end)
    c:connect_signal("property::maximized", widget.update)
    return widget
end

function mytitlebar:minimizebutton(c)
    local widget = mytitlebar:button(c, "minimize",
                                     function(cl)
                                         return ""
                                     end,
                                     function(cl)
                                         wmapi:on_minimized(cl)
                                     end)
    c:connect_signal("property::minimize", widget.update)
    return widget
end

function mytitlebar:closebutton(c)
    local widget = mytitlebar:button(c, "close",
                                     function(cl)
                                         return ""
                                     end,
                                     function(cl)
                                         wmapi:on_close(cl)
                                     end)
    c:connect_signal("property::close", widget.update)
    return widget
end

function mytitlebar:ontopbutton(c)
    local widget = mytitlebar:button(c, "ontop",
                                     function(cl)
                                         return cl.ontop
                                     end,
                                     function(cl, state)
                                         wmapi:on_ontop(cl, state)
                                     end)
    c:connect_signal("property::ontop", widget.update)
    return widget
end

function mytitlebar:stickybutton(c)
    local widget = mytitlebar:button(c, "sticky",
                                     function(cl)
                                         return cl.sticky
                                     end,
                                     function(cl, state)
                                         wmapi:on_sticky(cl, state)
                                     end)
    c:connect_signal("property::sticky", widget.update)
    return widget
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

                          if not startup then
                              if not c.size_hints.user_position and not c.size_hints.program_position then
                                  awful.placement.no_overlap(c)
                                  awful.placement.no_offscreen(c)
                              end
                          end

                          local buttons  = awful.util.table.join(
                                  awful.button({}, event.mouse.button_click_left,
                                               function()
                                                   client.focus = c
                                                   c:raise()
                                                   awful.mouse.client.move(c)
                                               end),
                                  awful.button({}, event.mouse.button_click_right,
                                               function()
                                                   if c.floating then
                                                       client.focus = c
                                                       c:raise()
                                                       awful.mouse.client.resize(c)
                                                   end
                                               end)
                          )

                          local titlebar = awful.titlebar(c, {
                              --bg       = awful.titlebar.titlebar_color or "#00ff00",
                              size     = beautiful.titlebars_size,
                              position = beautiful.titlebars_position,
                              font     = beautiful.titlebars_font,
                          })

                          titlebar:setup {
                              {
                                  {
                                      clienticon(c),
                                      layout = wibox.layout.align.horizontal()
                                  },
                                  margins = 3,
                                  widget  = wibox.container.margin(),

                              },
                              {
                                  align   = "center",
                                  buttons = buttons,
                                  widget  = mytitlebar:titlewidget(c),
                              },
                              {
                                  mytitlebar:minimizebutton(c),
                                  mytitlebar:maximizedbutton(c),
                                  mytitlebar:closebutton(c),

                                  layout = wibox.layout.align.horizontal()
                              },
                              layout = wibox.layout.align.horizontal()
                          }
                      end
)
