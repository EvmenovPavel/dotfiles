local widget = {}

function widget:button()
    return require("wmapi.widget.button")()
end

function widget:checkbox(argc)
    return require("wmapi.widget.checkbox")(argc)

end

function widget:graph(argc)
    return require("wmapi.widget.graph")(argc)

end

function widget:imagebox(argc)
    return require("wmapi.widget.imagebox")(argc)

end

function widget:launcher(argc)
    return require("wmapi.widget.launcher")(argc)

end

function widget:piechart(argc)
    return require("wmapi.widget.piechart")(argc)

end

function widget:popup(argc)
    return require("wmapi.widget.popup")(argc)

end

function widget:progressbar(argc)
    return require("wmapi.widget.progressbar")(argc)

end

function widget:separator(argc)
    return require("wmapi.widget.separator")(argc)

end

function widget:slider(argc)
    return require("wmapi.widget.slider")(argc)

end

function widget:textbox(argc)
    return require("wmapi.widget.textbox")(argc)
end

function widget:textclock(argc)
    return require("wmapi.widget.textclock")(argc)

end

function widget:box(argc)
    return require("wmapi.widget.box")(argc)

end

return widget