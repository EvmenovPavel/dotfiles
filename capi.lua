-- Global --

LuaTypes = {
    null     = "nil",
    boolean  = "boolean",
    number   = "number", str = "string",
    fun      = "function",
    userdata = "userdata",
    thread   = "thread",
    table    = "table",
    screen   = "screen"
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
    primary    = 2, -- remove
    root       = root,
    screen     = screen,
    tag        = tag,
    dbus       = dbus,
    button     = button,
    client     = client,
    awesome    = awesome,
    mouse      = mouse,
    timer      = timer,
    unpack     = unpack,
    keygrabber = keygrabber,

    home       = os.getenv("HOME"),
    awesomewm  = os.getenv("HOME") .. "/.config/awesome",
    devices    = os.getenv("HOME") .. "/.config/awesome/devices",
    wmapi      = require("wmapi"),
    log        = require("logger"),
}
