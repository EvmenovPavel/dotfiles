---------------------------------------------------------------------------
--- Collection of containers that can be used in widget boxes
--
-- @author Uli Schlachter
-- @copyright 2010 Uli Schlachter
-- @classmod wibox.container
---------------------------------------------------------------------------
local base = require("lib.wibox.widget.base")

return setmetatable({
                        rotate            = require("lib.wibox.container.rotate");
                        margin            = require("lib.wibox.container.margin");
                        mirror            = require("lib.wibox.container.mirror");
                        constraint        = require("lib.wibox.container.constraint");
                        scroll            = require("lib.wibox.container.scroll");
                        background        = require("lib.wibox.container.background");
                        radialprogressbar = require("lib.wibox.container.radialprogressbar");
                        arcchart          = require("lib.wibox.container.arcchart");
                        place             = require("lib.wibox.container.place");
                    }, { __call = function(_, args)
    return base.make_widget_declarative(args)
end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
