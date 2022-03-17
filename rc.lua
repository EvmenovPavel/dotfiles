-- Dir --
--package.path = package.path .. ";dir"
--package.path = package.path .. ";modules"

-- Include libs --
require("lib.global")
require("lib.dir")
require("lib.wmapi")

-- Global type --
log           = require("modules.logging")
notifications = require("modules.notifications")
resources     = require("resources.resources")
-- Start --
require("main")
--require("dirtree")
--require("signals")
