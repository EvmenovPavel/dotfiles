local widget = {}

---@param name_type string
function widget:base(name_type)
    return require("lib.widget.base.abase"):init(name_type)
end

function widget:button(text, src, key, event, func)
    return require("lib.widget.button.abutton"):init(text, src, key, event, func)
end

function widget:textbox(text)
    return require("lib.widget.textbox.atextbox"):init(text)
end

function widget:checkbox(text, src, key, event, func)
    return require("lib.widget.checkbox.acheckbox"):init(text, src, key, event, func)
end

function widget:combobox(argc)
    return require("lib.widget.combobox.acombobox"):init(argc)
end

function widget:graph(argc)
    return require("lib.widget.graph.agraph"):init(argc)
end

---@overload fun(image:string):widget
---@overload fun(image:string,resize:number):widget
---@overload fun(image:string,resize:number,forced_width:number):widget
---@overload fun(image:string,resize:number,forced_width:number,forced_height:number):widget
---@overload fun(image:string,resize:number,forced_width:number,forced_height:number,clip_shape:fun()):widget
---@param image string
---@param resize number
---@param forced_width number
---@param forced_height number
---@param clip_shape fun()
function widget:imagebox(image, resize, forced_width, forced_height, clip_shape)
    return require("lib.widget.imagebox.aimagebox"):init(image, resize, forced_width, forced_height, clip_shape)
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
    return require("lib.widget.messagebox.messagebox"):init()
end

function widget:calendar()
    return require("lib.widget.calendar.calendar")--:init()
end

function widget:prompt(args)
    return require("lib.widget.prompt.promptbox").new(args)--:init()
end

return widget