local awful               = require("awful")
local wibox               = require("wibox")
local dpi                 = require("beautiful").xresources.apply_dpi

local beautiful           = require("beautiful")
local gears               = require("gears")
local rubato              = require("3rdparty.rubato")

local transition_duration = 0.3
local icon_size           = 28
local dot_size            = 1.5
local number_of_tags      = 10

local taglist             = {}

function create_callback1(self, c3, index, objects)
	local old_cursor, old_wibox

	--mouse::enter
	--mouse::leave
	--mouse::press
	--mouse::release
	--mouse::move

	self:connect_signal(
			"mouse::enter",
			function()
				local w = _G.mouse.current_wibox
				if w then
					old_cursor, old_wibox = w.cursor, w
					w.cursor              = "hand1"
				else
					self.bg = "#ffffff11"
				end
			end
	)

	-- TODO
	-- ошибка принаведении курсором на тег
	self:connect_signal(
			"mouse::leave",
			function()
				if old_wibox then
					old_wibox.cursor = old_cursor
					old_wibox        = nil
				else
					self.bg = "#ffffff00"
				end
			end
	)

	--self:connect_signal(
	--        "button::press",
	--        function()
	--            self.bg = "#ffffff22"
	--        end
	--)

	--self:connect_signal(
	--        "button::release",
	--        function()
	--            self.bg = "#ffffff11"
	--        end
	--)
end

local function update_callback1(w, buttons, label, data, objects)
	w:reset()
	for i, o in ipairs(objects) do
		local cache = data[o]
		local ib, tb, bgb, tbm, ibm, l, bg_clickable
		if cache then
			ib  = cache.ib
			tb  = cache.tb
			bgb = cache.bgb
			tbm = cache.tbm
			ibm = cache.ibm
		else
			local icondpi = 3
			ib            = wibox.widget.imagebox()
			tb            = wibox.widget.textbox()
			bgb           = wibox.container.background()
			tbm           = wibox.container.margin(tb, dpi(4), dpi(16))
			ibm           = wibox.container.margin(ib, dpi(icondpi), dpi(icondpi), dpi(icondpi), dpi(icondpi))
			l             = wibox.layout.fixed.horizontal()
			bg_clickable  = wmapi:container()

			l:fill_space(true)
			l:add(ibm)
			bg_clickable:set_widget(l)

			bgb:set_widget(bg_clickable)

			data[o] = {
				ib  = ib,
				tb  = tb,
				bgb = bgb,
				tbm = tbm,
				ibm = ibm
			}
		end

		local text, bg, bg_image, icon, args = label(o, tb)
		args                                 = args or {}

		bgb:set_bg(bg)
		if type(bg_image) == "function" then
			-- TODO: Why does this pass nil as an argument?
			bg_image = bg_image(tb, o, nil, objects, i)
		end

		bgb:set_bgimage(bg_image)
		if icon then
			ib.image = icon
		else
			ibm:set_margins(0)
		end

		bgb.shape              = args.shape
		bgb.shape_border_width = args.shape_border_width
		bgb.shape_border_color = args.shape_border_color

		w:add(bgb)
	end
end

local function buttons()
	return awful.util.table.join(
			awful.button({},
					event.mouse.button_click_left,
					function(c)
						c:view_only()
					end
			)
	)
end

local function widget_template()
	return {
		{
			{
				id     = "icon_role",
				widget = wibox.widget.imagebox,
			},
			{
				id     = "text_role",
				widget = wibox.widget.textbox,
			},
			layout = wibox.layout.fixed.horizontal,
		},
		id              = "background_role",
		widget          = wibox.container.background,

		create_callback = create_callback1
	}
end

local function create_resize_transition()
	return rubato.timed {
		pos      = dpi(icon_size),
		intro    = 0,
		duration = transition_duration,
		easing   = rubato.linear
	}
end

local taglist_item_transitions = {}
for i = 1, number_of_tags do
	taglist_item_transitions[i] = create_resize_transition()
end

local floating_indicator_transition = rubato.timed {
	pos      = 0,
	intro    = 0,
	duration = transition_duration,
	easing   = rubato.linear
}

local indicator_widget              = wibox.widget {
	{
		forced_height = dpi(icon_size),
		-- если переключаешься быстро
		-- делает сдвиги
		forced_width  = dpi(icon_size * dot_size),
		shape         = gears.shape.rounded_bar,
		bg            = beautiful.taglist_bg_focus,
		widget        = wibox.container.background,
	},
	left   = 0,
	widget = wibox.container.margin
}

-- Helper function that updates a taglist item
--local update_taglist                = function(item, tag, index)
local function update_taglist(item, tag, index)
	if tag.selected then
		taglist_item_transitions[index].target = dpi(icon_size)
	else
		taglist_item_transitions[index].target = dpi(icon_size * dot_size)
		floating_indicator_transition.target   = (beautiful.taglist_spacing + icon_size) * (index - 1)
	end
end

function taglist:init(s)
	local create_taglist = function(item, tag, index)
		-- bling: Only show widget when there are clients in the tag
		item:connect_signal("mouse::enter", function()
			if #tag:clients() > 0 then
				awesome.emit_signal("bling::tag_preview::update", tag)
				awesome.emit_signal("bling::tag_preview::visibility", s, true)
			end
		end)

		item:connect_signal("mouse::leave", function()
			-- bling: Turn the widget off
			awesome.emit_signal("bling::tag_preview::visibility", s, false)

			if item.has_backup then
				item.bg = item.backup
			end
		end)

		taglist_item_transitions[index]:subscribe(function(value)
			item.forced_width = value
		end)
		floating_indicator_transition:subscribe(function(value)
			indicator_widget.left = value
		end)

		update_taglist(item, tag, index)
	end

	local tl             = awful.widget.taglist {
		screen          = s,
		filter          = awful.widget.taglist.filter.all,
		buttons         = buttons(),
		layout          = wibox.layout.fixed.horizontal,
		style           = {
			--taglist_count          = 10,
			--taglist_spacing        = 10,
			--taglist_squares_resize = true,

			spacing = 0,
			--taglist_spacing = ,

			--shape_border_width = 1,
			--shape_border_color = "#ffffff20",
			--shape              = function(cr, width, height)
			--    gears.shape.transform(gears.shape.rounded_rect):translate(width, 0)(cr, 0, height, 0)
			--end,

			--update_function = list_update,
			--shape = gears.shape.powerline
		},
		widget_template = {
			{
				{
					id     = "icon_role",
					widget = wibox.widget.imagebox,
				},
				{
					id     = "text_role",
					widget = wibox.widget.textbox,
				},
				layout = wibox.layout.fixed.horizontal,
			},
			id              = "background_role",
			--forced_width    = icon_size,
			widget          = wibox.container.background,
			create_callback = create_taglist,
			update_callback = update_taglist,
		}
	}

	return tl

	--return wibox.widget {
	--    {
	--        tl,
	--        {
	--            indicator_widget,
	--            widget = wibox.layout.fixed.horizontal,
	--        },
	--        layout = wibox.layout.stack
	--    },
	--    top    = dpi(12),
	--    bottom = dpi(12),
	--    widget = wibox.container.margin
	--}
end

-- Tag preview
--bling.widget.tag_preview.enable {
--    show_client_content = true,
--    placement_fn        = function(c)
--        awful.placement.top_left(c, {
--            margins = {
--                top  = beautiful.top_bar_height + DPI(10),
--                left = DPI(10)
--            }
--        })
--    end,
--    scale               = 0.16,
--    honor_padding       = true,
--    honor_workarea      = true,
--    background_widget   = wibox.widget {
--        widget = wibox.container.background,
--        bg     = beautiful.wallpaper
--    }
--}

return setmetatable(taglist, { __call = function(_, ...)
	return taglist:init(...)
end })
