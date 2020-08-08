-- Do some evil monkeypatching for upstreamable widgets
local wibox = require("wibox")

--wibox.layout.grid     = require( "widgets.radical.widgets.grid"     )
-- wibox.widget.checkbox = require( "widgets.radical.widgets.checkbox" )
-- wibox.widget.slider   = require( "widgets.radical.widgets.slider"   )

return {
    scroll          = require("widgets.radical.widgets.scroll"),
    filter          = require("widgets.radical.widgets.filter"),
    fkey            = require("widgets.radical.widgets.fkey"),
    table           = require("widgets.radical.widgets.table"),
    header          = require("widgets.radical.widgets.header"),
    piechart        = require("widgets.radical.widgets.piechart"),
    separator       = require("widgets.radical.widgets.separator"),
    infoshapes      = require("widgets.radical.widgets.infoshapes"),
    constrainedtext = require("widgets.radical.widgets.constrainedtext"),
}
