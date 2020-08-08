---------------------------------------------------------------------------
--- Widget module for awful
--
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008-2009 Julien Danjou
-- @classmod awful.widget
---------------------------------------------------------------------------

return
{
    taglist        = require("lib.awful.widget.taglist");
    tasklist       = require("lib.awful.widget.tasklist");
    layoutlist     = require("lib.awful.widget.layoutlist");
    button         = require("lib.awful.widget.button");
    launcher       = require("lib.awful.widget.launcher");
    prompt         = require("lib.awful.widget.prompt");
    progressbar    = require("lib.awful.widget.progressbar");
    graph          = require("lib.awful.widget.graph");
    layoutbox      = require("lib.awful.widget.layoutbox");
    textclock      = require("lib.awful.widget.textclock");
    keyboardlayout = require("lib.awful.widget.keyboardlayout");
    watch          = require("lib.awful.widget.watch");
    only_on_screen = require("lib.awful.widget.only_on_screen");
    clienticon     = require("lib.awful.widget.clienticon");
    calendar_popup = require("lib.awful.widget.calendar_popup");
    common         = require("lib.awful.widget.common");
}

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
