---------------------------------------------------------------------------
--- This module is deprecated and has been renamed to `awful.wibar`
--
-- This only deprecates `awful.wibox`, but not @{wibox}.
--
-- @author Emmanuel Lepage Vallee &lt;elv1313@gmail.com&gt;
-- @copyright 2016 Emmanuel Lepage Vallee
-- @module awful.wibox
---------------------------------------------------------------------------
local gdebug = require("lib.gears.debug")

return gdebug.deprecate_class(require("lib.awful.wibar"), "lib.awful.wibox", "lib.awful.wibar")

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
