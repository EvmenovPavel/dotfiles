local wibox       = require("lib.wibox")
local awful       = require("lib.awful")
local beautiful   = require("lib.beautiful")
local widget      = require("util.widgets")
local helpers     = require("helpers")

-- beautiful vars
local fg_read     = beautiful.widget_email_fg_read
local fg_unread   = beautiful.widget_email_fg_unread
local bg          = beautiful.widget_email_bg
local l           = beautiful.widget_email_layout or 'horizontal'
local w_type      = beautiful.widget_email_type or 'text'
local padding     = beautiful.widget_popup_padding or 1
local spacing     = beautiful.widget_spacing or 1

local read_icon   = w_type == 'button' and " " .. beautiful.widget_email_read_icon .. " "
        or beautiful.widget_email_read_icon
local unread_icon = w_type == 'button' and " " .. beautiful.widget_email_unread_icon .. " " or beautiful.widget_email_unread_icon

-- colour
local d_grey      = beautiful.grey_dark or "#222222"
local fg_grey     = beautiful.fg_grey or "#a9a9a9"

-- widget creation
local icon
if w_type == 'button' then
    icon = widget.create_title(unread_icon, fg_unread)
else
    icon        = widget.base_icon()
    icon.markup = helpers.colorize_text(unread_icon, fg_unread)
end

local text         = widget.base_text()

local email_widget = w_type == 'button' and icon
        or widget.box_with_margin(l, { icon, text }, spacing)

local popup_title  = widget.create_title("Last messages:", fg_grey)
local popup_msg    = {}
for i = 1, 4 do
    popup_msg[i] = widget.base_text()
end

local w = awful.popup {
    widget              = {
        {
            layout = wibox.layout.align.horizontal
        },
        {
            {
                {
                    popup_title,
                    popup_msg[1],
                    popup_msg[2],
                    popup_msg[3],
                    popup_msg[4],
                    layout = wibox.layout.align.vertical
                },
                layout = wibox.layout.align.horizontal
            },
            margins = 10,
            widget  = wibox.container.margin
        },
        {
            layout = wibox.layout.align.horizontal
        },
        layout = wibox.layout.fixed.horizontal
    },
    visible             = false,
    ontop               = true,
    hide_on_right_click = true,
    offset              = { y = padding, x = padding },
    bg                  = d_grey
}

w:bind_to_widget(email_widget)

-- tooltip if beautiful.widget_email_type = 'button' is used
local tt
if w_type == 'button' then
    tt = awful.tooltip {
        markup  = 0,
        visible = false,
        objects = { email_widget }
    }
end

local grab_emails_script = [[
  bash -c "
  ~/.config/awesome/widgets/email.sh get ~/.mails
"]]

awful.widget.watch(grab_emails_script, 300, -- 5m
                   function(widget, stdout, stderr, exitreason, exitcode)
                       local filter_mail = stdout:match('%d+') or 0
                       local mail_num    = tonumber(filter_mail) or 0
                       if (mail_num > 0) then
                           icon.markup = helpers.colorize_text(read_icon, fg_read)
                           text.markup = helpers.colorize_text(mail_num, fg_read)
                           tt.markup   = helpers.colorize_text("You got " .. mail_num .. " messages", fg_read)
                       else
                           icon.markup = helpers.colorize_text(unread_icon, fg_unread)
                           text.markup = helpers.colorize_text(0, fg_read)
                           tt.markup   = helpers.colorize_text("No new messages", fg_read)
                       end
                   end
)

local show_emails_script = [[
  bash -c "
  ~/.config/awesome/widgets/email.sh show ~/.mails
"]]

local function update_popup()
    awful.widget.watch(show_emails_script, 60, function(widget, stdout)
        local msg                      = {}
        msg[1], msg[2], msg[3], msg[4] = stdout:match('[|]*([%s%w@."]*)[|]*([%s%w@."]*)[|]*([%s%w@."]*)[|]*([%s%w@."]*)')

        for i = 1, 4 do
            msg[i] = tostring(msg[i]) or nil
            if msg[i] ~= tostring(nil) and msg[i] ~= '' then
                popup_msg[i].markup = helpers.colorize_text(i .. " - From: " .. msg[i], fg_grey)
            else
                popup_msg[i].markup = ''
            end
        end

    end)
end

update_popup()

return email_widget
