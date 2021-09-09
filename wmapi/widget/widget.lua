local widget = {}

function widget:button(argc)
    return require("wmapi.widget.button"):create(argc)
end

function widget:checkbox(argc)
    return require("wmapi.widget.checkbox"):create(argc)

end

function widget:graph(argc)
    return require("wmapi.widget.graph"):create(argc)

end

function widget:imagebox(argc)
    return require("wmapi.widget.imagebox"):create(argc)
end

function widget:launcher(argc)
    return require("wmapi.widget.launcher"):create(argc)

end

function widget:piechart(argc)
    return require("wmapi.widget.piechart"):create(argc)

end

function widget:popup(argc)
    return require("wmapi.widget.popup"):create(argc)

end

function widget:progressbar(argc)
    return require("wmapi.widget.progressbar"):create(argc)

end

function widget:separator(argc)
    return require("wmapi.widget.separator"):create(argc)

end

function widget:slider(argc)
    return require("wmapi.widget.slider"):create(argc)

end

function widget.textbox(argc)
    return require("wmapi.widget.textbox"):create(argc)
end

function widget:textclock(argc)
    return require("wmapi.widget.textclock"):create(argc)

end

function widget:box(argc)
    return require("wmapi.widget.box"):create(argc)

end

return widget