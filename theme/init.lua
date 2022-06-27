local theme     = require("theme.theme")
local titlebar  = require("theme.titlebar")
local taglist   = require("theme.taglist")
local tasklist  = require("theme.tasklist")
local menu      = require("theme.menu")
local wibar     = require("theme.wibar")

local beautiful = {}

function beautiful:theme(config)
    theme:init(config)
end

function beautiful:titlebar(config)
    titlebar:init(config)
end

function beautiful:taglist(config)
    taglist:init(config)
end

function beautiful:tasklist(config)
    tasklist:init(config)
end

function beautiful:menu(config)
    menu:init(config)
end

function beautiful:wibar(config)
    wibar:init(config)
end

return beautiful