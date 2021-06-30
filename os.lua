local BinaryFormat = package.cpath:match("%p[\\|/]?%p(%a+)")
if BinaryFormat == "dll" then
    function os.name()
        return "Windows"
    end
elseif BinaryFormat == "so" then
    function os.name()
        return "Linux"
    end
elseif BinaryFormat == "dylib" then
    function os.name()
        return "MacOS"
    end
end
BinaryFormat = nil



function os.capture(cmd, raw)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    if raw then
        return s
    end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
    return s
end


local uname  = io.popen("getent passwd $USER | cut -d ':' -f 5 | cut -d ',' -f 1"):read()


local f = io.popen("lsb_release -a")
local s = f:read("*a")
print(s)
f:close()
--# Do something with s...


local uname  = io.popen("getent passwd $USER | cut -d ':' -f 5 | cut -d ',' -f 1"):read()
print(uname)

local lscpu  = io.popen("lscpu"):read()
print(lscpu)

local f = io.popen("lsb_release -a")
local s = f:read("*a")
print(s)
f:close()
--# Do something with s...



-- $ lscpu | grep -E '^Thread|^Core|^Socket|^CPU\('