local awful         = require("awful")
local resources     = require("resources")

local restart       = {}

local myawesomemenu = {
    { "restart_1", awesome.restart },
    { "restart_2", function()
        awesome.restart()
    end },
}

local mymainmenu    = awful.menu({
                                     items = {
                                         { "awesome", myawesomemenu, resources.checkbox.checkbox },
                                         { "open terminal", "terminal" }
                                     }
                                 })

local map, actions  = {
    verbs      = {
        m = "move", f = "focus", d = "delete", a = "append",
        w = "swap", p = "print", n = "new",
    },
    adjectives = { h = "left", j = "down", k = "up", l = "right", },
    nouns      = { c = "client", t = "tag", s = "screen", y = "layout", },
}, {}

function actions.client(action, adj)
    print("IN CLIENT!")
    capi.log:message("IN CLIENT!")
end --luacheck: no unused args
function actions.tag   (action, adj)
    print("IN TAG!")
    capi.log:message("IN TAG!")
end --luacheck: no unused args
function actions.screen(action, adj)
    print("IN SCREEN!")
    capi.log:message("IN SCREEN!")
end --luacheck: no unused args
function actions.layout(action, adj)
    print("IN LAYOUT!")
    capi.log:message("IN LAYOUT!")
end --luacheck: no unused args

local function parse(_, stop_key, _, sequence)
    local parsed, count = { verbs = "", adjectives = "", nouns = "", }, ""
    sequence            = sequence .. stop_key

    for i = 1, #sequence do
        local char = sequence:sub(i, i)
        if char >= "0" and char <= "9" then
            count = count .. char
        else
            for kind in pairs(parsed) do
                parsed[kind] = map[kind][char] or parsed[kind]
            end
        end
    end

    if parsed.nouns == "" then
        return
    end
    for _ = 1, count == "" and 1 or tonumber(count) do
        actions[parsed.nouns](parsed.verbs, parsed.adjectives)
    end
end

local restart = {}

function restart:init()
    local s = capi.widget:button(
            {
                func = function()
                    awesome.restart()
                end
            }
    )

    return s:get()
end

return setmetatable(restart, { __call = function()
    return restart:init()
end })
