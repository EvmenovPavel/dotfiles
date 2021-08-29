--{
--    orientation   = "horizontal",
--    forced_height = 15,
--    color         = beautiful.bg_focus,
--    widget        = wibox.widget.separator
--},

return {
    buttons     = require("wmapi.widget.buttons"),
    checkbox    = require("wmapi.widget.checkbox"),
    graph       = require("wmapi.widget.graph"),
    imagebox    = require("wmapi.widget.imagebox"),
    launcher    = require("wmapi.widget.launcher"),
    piechart    = require("wmapi.widget.piechart"),
    popup       = require("wmapi.widget.popup"),
    progressbar = require("wmapi.widget.progressbar"),
    separator   = require("wmapi.widget.separator"),
    slider      = require("wmapi.widget.slider"),
    textbox     = require("wmapi.widget.textbox"),
    textclock   = require("wmapi.widget.textclock"),
}