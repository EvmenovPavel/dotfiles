---------------------------------------------------------------------------
--- AWesome Functions very UsefuL
--
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @module awful
---------------------------------------------------------------------------

-- TODO: This is a hack for backwards-compatibility with 3.5, remove!
local util   = require("lib.awful.util")
local gtimer = require("lib.gears.timer")
local gdebug = require("lib.gears.debug")
function timer(...)
    -- luacheck: ignore
    gdebug.deprecate("gears.timer", { deprecated_in = 4 })
    return gtimer(...)
end

--TODO: This is a hack for backwards-compatibility with 3.5, remove!
-- Set awful.util.spawn* and awful.util.pread.
local spawn           = require("lib.awful.spawn")

util.spawn            = function(...)
    gdebug.deprecate("awful.spawn", { deprecated_in = 4 })
    return spawn.spawn(...)
end

util.spawn_with_shell = function(...)
    gdebug.deprecate("awful.spawn.with_shell", { deprecated_in = 4 })
    return spawn.with_shell(...)
end

util.pread            = function()
    gdebug.deprecate("Use io.popen() directly or look at awful.spawn.easy_async() "
                             .. "for an asynchronous alternative", { deprecated_in = 4 })
    return ""
end

return
{
    client               = require("lib.awful.client");
    completion           = require("lib.awful.completion");
    layout               = require("lib.awful.layout");
    placement            = require("lib.awful.placement");
    prompt               = require("lib.awful.prompt");
    screen               = require("lib.awful.screen");
    tag                  = require("lib.awful.tag");
    util                 = require("lib.awful.util");
    widget               = require("lib.awful.widget");
    keygrabber           = require("lib.awful.keygrabber");
    menu                 = require("lib.awful.menu");
    mouse                = require("lib.awful.mouse");
    remote               = require("lib.awful.remote");
    key                  = require("lib.awful.key");
    button               = require("lib.awful.button");
    wibar                = require("lib.awful.wibar");
    wibox                = require("lib.awful.wibox");
    startup_notification = require("lib.awful.startup_notification");
    tooltip              = require("lib.awful.tooltip");
    ewmh                 = require("lib.awful.ewmh");
    titlebar             = require("lib.awful.titlebar");
    rules                = require("lib.awful.rules");
    popup                = require("lib.awful.popup");
    spawn                = spawn;
}

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
