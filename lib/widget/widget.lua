local widget = {}

---@param name string
function widget:base(name)
    return require("lib.widget.base.abase"):init(name)
end

---@overload fun():widget
function widget:button()
    return require("lib.widget.button.abutton"):init()
end

---@overload fun():widget
function widget:textbox()
    return require("lib.widget.textbox.atextbox"):init()
end

---@overload fun():widget
function widget:checkbox()
    return require("lib.widget.checkbox.acheckbox"):init()
end

---@overload fun():widget
function widget:combobox()
    return require("lib.widget.combobox.acombobox"):init()
end

---@overload fun():widget
function widget:graph(argc)
    return require("lib.widget.graph.agraph"):init(argc)
end

---@overload fun():widget
function widget:imagebox()
    return require("lib.widget.imagebox.aimagebox"):init()
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

function widget:switch()
    return require("lib.widget.switch.aswitch"):init()
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
    return require("lib.widget.messagebox.messagebox")
end

function widget:calendar()
    return require("lib.widget.calendar.calendar")
end

function widget:prompt()
    return require("lib.widget.prompt.promptbox"):init()
end

function widget:window()
    return require("lib.widget.window.awindow"):init()
end

return widget