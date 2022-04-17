local widget = {}

function widget:base(shape)
    return require("lib.widget.base.abase"):init(shape)
end

function widget:button(text, src, key, event, func)
    return require("lib.widget.button.abutton"):init(key, event, func, text, src)
end

function widget:textbox(text, valign, align)
    return require("lib.widget.textbox.atextbox"):init(text, valign, align)
end

function widget:checkbox()
    return require("lib.widget.checkbox.acheckbox"):init()
end

function widget:combobox(argc)
    return require("lib.widget.combobox.acombobox"):init(argc)
end

function widget:graph(argc)
    return require("lib.widget.graph.agraph"):init(argc)
end

function widget:imagebox(argc)
    return require("lib.widget.imagebox.aimagebox"):init(argc)
end

function widget:launcher(argc)
    return require("lib.widget.launcher.alauncher"):init(argc)
end

function widget:piechart(argc)
    return require("lib.widget.piechart.apiechart"):init(argc)
end

function widget:popup(argc)
    return require("lib.widget.popup.apopup"):init(argc)
end

function widget:progressbar(argc)
    return require("lib.widget.progressbar.aprogressbar"):init(argc)
end

function widget:separator(argc)
    return require("lib.widget.separator.aseparator"):init(argc)
end

function widget:slider(argc)
    return require("lib.widget.slider.aslider"):init(argc)
end

function widget:textclock(argc)
    return require("lib.widget.textclock.atextclock"):init(argc)
end

function widget:box(argc)
    return require("lib.widget.box.abox"):init(argc)
end

function widget:switch(argc)
    return require("lib.widget.switch.aswitch"):init(argc)
end

function widget:hradiobox()
    return require("lib.widget.hradiobox.ahradiobox"):init()
end

function widget:vradiobox()
    return require("lib.widget.vradiobox.avradiobox"):init()
end

function widget:verticallayout(argc)
    return require("lib.widget.verticallayout.averticallayout"):init(argc)
end

function widget:horizontallayout(argc)
    return require("lib.widget.horizontallayout.ahorizontallayout"):init(argc)
end

function widget:messagebox()
    return require("lib.widget.messagebox.messagebox"):init()
end

return widget