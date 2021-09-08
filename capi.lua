-- Global --

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
    imagebox = "imagebox"
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
    primary    = 1, -- remove

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
