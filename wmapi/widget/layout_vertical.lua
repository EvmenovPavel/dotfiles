local wibox           = require("wibox")

local layout_vertical = {}

function layout_vertical:create()
    local layout  = {}

    layout.widget = wibox.widget({
                                     expend      = true,
                                     homogeneous = false,
                                     spacing     = 0,

                                     layout      = wibox.layout.grid,
                                 })

    function layout:get()
        return self.widget
    end

    layout.row_size = 1

    function layout:add_widget_at(widget, height, width)
        -- 1) позиция row
        -- 2) позиция column
        -- 3) высота
        -- 4) длина

        if LuaWidgetTypes[widget:get().type] then
            widget = widget:get()
        else
            widget = widget
        end

        local height = height or 1
        local width  = width or 1

        self.widget:add_widget_at(widget, layout.row_size, 1, height, width)
        layout.row_size = layout.row_size + 1
    end

    function layout:insert_row()
        self.widget:insert_row(1)
    end

    function layout:remove(index)
        local index = index or 1
    end

    return layout
end

return layout_vertical