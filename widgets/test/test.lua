local resources     = require("resources")
local menu          = require("menu")

local test          = {}

local myawesomemenu = {
    { "restart_1",
      function()
          awesome.restart()
      end
    },
    { "restart_2", function()
        awesome.restart()
    end },
}

local mymainmenu    = menu({
                               items = {
                                   { "awesome", myawesomemenu, resources.checkbox.checkbox },
                                   { "open terminal", "terminal" }
                               }
                           })

function test:init()
    local widget = capi.widget:launcher({
                                            image = resources.checkbox.checkbox,
                                            menu  = mymainmenu
                                        })

    return widget
end

return setmetatable(test, { __call = function(_, ...)
    return test:init(...)
end })
