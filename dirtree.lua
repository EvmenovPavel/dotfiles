local lfs        = require("lfs")

local debug      = debug or debug

local source     = string.sub(debug.getinfo(1).source, 2)
local path       = string.sub(source, 1, string.find(source, "/[^/]*$"))

local ignore_dir = { ".git", ".idea", "lib", "resources" }

local function ignore(find)
    for _, i in ipairs(ignore_dir) do
        if i == find then
            return true
        end
    end

    return false
end

function dirtree(dir)
    assert(dir and dir ~= "", "Please pass directory parameter")
    if string.sub(dir, -1) == "/" then
        dir = string.sub(dir, 1, -2)
    end

    local function yieldtree(dir)
        for entry in lfs.dir(dir) do
            if entry ~= "." and entry ~= ".." then
                if not ignore(entry) then
                    entry      = dir .. "/" .. entry
                    local attr = lfs.attributes(entry)
                    coroutine.yield(entry, attr)
                    if attr.mode == "directory" then
                        yieldtree(entry)
                    end
                end
            end
        end
    end

    return coroutine.wrap(function()
        yieldtree(dir)
    end)
end

for filename, attr in dirtree(path) do
    if attr.mode == "directory" then
        local src    = ";" .. filename .. "/?.lua"
        package.path = package.path .. src
    end
end
