-- Global --
local gears    = require("gears")

LuaTypes       = {
    null     = "nil",
    boolean  = "boolean",
    number   = "number",
    str      = "string",
    fun      = "function",
    userdata = "userdata",
    thread   = "thread",
    table    = "table",
    screen   = "screen"
}

LuaWidgetTypes = {
    box         = "box",
    button      = "button",
    checkbox    = "checkbox",
    graph       = "graph",
    imagebox    = "imagebox",
    launcher    = "launcher",
    piechart    = "piechart",
    popup       = "popup",
    progressbar = "progressbar",
    separator   = "separator",
    slider      = "slider",
    textbox     = "textbox",
    textclock   = "textclock",
    switch      = "switch",
    radiobox    = "radiobox",
}

ShapeStyle     = {
    rounded_rect           = gears.shape.rounded_rect,
    rounded_bar            = gears.shape.rounded_bar,
    partially_rounded_rect = gears.shape.partially_rounded_rect,
    infobubble             = gears.shape.infobubble,
    rectangular_tag        = gears.shape.rectangular_tag,
    arrow                  = gears.shape.arrow,
    hexagon                = gears.shape.hexagon,
    powerline              = gears.shape.powerline,
    isosceles_triangle     = gears.shape.isosceles_triangle,
    cross                  = gears.shape.cross,
    octogon                = gears.shape.octogon,
    circle                 = gears.shape.circle,
    rectangle              = gears.shape.rectangle,
    parallelogram          = gears.shape.parallelogram,
    losange                = gears.shape.losange,
    pie                    = gears.shape.pie,
    arc                    = gears.shape.arc,
    radial_progress        = gears.shape.radial_progress,
}

function Type(var)
    for _, x in ipairs(LuaTypes) do
        if (type(var) == x) then
            return x
        end
    end
end

placement = {
    top          = "top",
    top_right    = "top_right",
    top_left     = "top_left",
    bottom_right = "bottom_right"
}

capi      = {
    primary    = 3,

    event      = require("wmapi.event"),
    timer      = require("wmapi.timer"),
    markup     = require("wmapi.markup"),
    widget     = require("wmapi.widget.widget"),
    containers = require("wmapi.container.container"),
    wmapi      = require("wmapi.wmapi"),

    home       = os.getenv("HOME"),
    awesomewm  = os.getenv("HOME") .. "/.config/awesome",
    devices    = os.getenv("HOME") .. "/.config/awesome/devices",
    log        = require("logger"),
}
