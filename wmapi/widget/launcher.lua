local gtable       = require("gears.table")
local spawn        = require("awful.spawn")
local wbutton      = require("awful.widget.button")
local button       = require("awful.button")

local launcher     = { }

launcher.mt        = {}

function launcher:init(args)
    if not args.command and not args.menu then
        return
    end
    local w = wbutton(args)
    if not w then
        return
    end

    local b
    if args.command then
        b = gtable.join(w:buttons(), button({}, 1, nil, function()
            spawn(args.command)
        end))
    elseif args.menu then
        b = gtable.join(w:buttons(), button({}, 1, nil, function()
            args.menu:toggle()
            --args.menu()
        end))
    end

    w:buttons(b)
    return w
end

return setmetatable(launcher, { __call = function(_, ...)
    return launcher:init(...)
end })
