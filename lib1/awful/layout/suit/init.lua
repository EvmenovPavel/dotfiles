---------------------------------------------------------------------------
--- Suits for awful
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @module awful.layout
---------------------------------------------------------------------------

return
{
    corner    = require("lib.awful.layout.suit.corner");
    max       = require("lib.awful.layout.suit.max");
    tile      = require("lib.awful.layout.suit.tile");
    fair      = require("lib.awful.layout.suit.fair");
    floating  = require("lib.awful.layout.suit.floating");
    magnifier = require("lib.awful.layout.suit.magnifier");
    spiral    = require("lib.awful.layout.suit.spiral");
}

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
