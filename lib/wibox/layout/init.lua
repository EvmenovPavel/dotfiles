---------------------------------------------------------------------------
--- Collection of layouts that can be used in widget boxes
--
-- @author Uli Schlachter
-- @copyright 2010 Uli Schlachter
-- @classmod wibox.layout
---------------------------------------------------------------------------
local base = require("lib.wibox.widget.base")

return setmetatable({
                        fixed      = require("lib.wibox.layout.fixed");
                        align      = require("lib.wibox.layout.align");
                        flex       = require("lib.wibox.layout.flex");
                        rotate     = require("lib.wibox.layout.rotate");
                        manual     = require("lib.wibox.layout.manual");
                        margin     = require("lib.wibox.layout.margin");
                        mirror     = require("lib.wibox.layout.mirror");
                        constraint = require("lib.wibox.layout.constraint");
                        scroll     = require("lib.wibox.layout.scroll");
                        ratio      = require("lib.wibox.layout.ratio");
                        stack      = require("lib.wibox.layout.stack");
                        grid       = require("lib.wibox.layout.grid");
                    }, { __call = function(_, args)
    return base.make_widget_declarative(args)
end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
