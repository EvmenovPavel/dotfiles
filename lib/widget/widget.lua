local widget = {}

function widget:button(text, src, key, event, func)
    return require("lib.widget.button.abutton"):create(text, src, key, event, func)
end

function widget:textbox(text, valign, align)
    return require("lib.widget.textbox.atextbox"):create(text, valign, align)
end

function widget:checkbox()
    return require("lib.widget.checkbox.acheckbox"):create()
end

function widget:combobox(argc)
    return require("lib.widget.combobox.acombobox"):create(argc)
end

function widget:graph(argc)
    return require("lib.widget.graph.agraph"):create(argc)
end

function widget:imagebox(argc)
    return require("lib.widget.imagebox.aimagebox"):create(argc)
end

function widget:launcher(argc)
    return require("lib.widget.launcher.alauncher"):create(argc)
end

function widget:piechart(argc)
    return require("lib.widget.piechart.apiechart"):create(argc)
end

function widget:popup(argc)
    return require("lib.widget.popup.apopup"):create(argc)
end

function widget:progressbar(argc)
    return require("lib.widget.progressbar.aprogressbar"):create(argc)
end

function widget:separator(argc)
    return require("lib.widget.separator.aseparator"):create(argc)
end

function widget:slider(argc)
    return require("lib.widget.slider.aslider"):create(argc)
end

function widget:textclock(argc)
    return require("lib.widget.textclock.atextclock"):create(argc)
end

function widget:box(argc)
    return require("lib.widget.box.abox"):create(argc)
end

function widget:switch(argc)
    return require("lib.widget.switch.aswitch"):create(argc)
end

function widget:hradiobox()
    return require("lib.widget.hradiobox.ahradiobox"):create()
end

function widget:vradiobox()
    return require("lib.widget.vradiobox.avradiobox"):create()
end

function widget:verticallayout(argc)
    return require("lib.widget.verticallayout.averticallayout"):create(argc)
end

function widget:horizontallayout(argc)
    return require("lib.widget.horizontallayout.ahorizontallayout"):create(argc)
end

return widget