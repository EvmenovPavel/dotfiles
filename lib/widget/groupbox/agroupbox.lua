local wibox           = require("wibox")

local layout_vertical = {}

function layout_vertical:create()
    local layout  = {}

    layout.widget = wibox.widget({
        homogeneous   = true,
        spacing       = 5,
        min_cols_size = 10,
        min_rows_size = 10,
        layout        = wibox.layout.grid,
    })

    function layout:get()
        return self.widget
    end

    local row_size = 1

    function layout:add_widget_at(widget, height, width)
        -- 1) позиция row
        -- 2) позиция column
        -- 3) высота
        -- 4) длина

        local widget = widget:get() or widget
        self.widget:add_widget_at(widget, row_size, 1, height, widget)
        row_size = row_size + 1
    end

    function layout:insert_row()
        l:insert_row(1)
    end

    function layout:remove(index)
        local index = index or 1
    end

    return layout
end

return layout_vertical