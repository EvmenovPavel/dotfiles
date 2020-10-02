local stdout = "1"

local cb1    = function(stdout)
    --stdout       = string.gsub(stdout, "\n", "")
    local status = stdout == "Playing" or stdout == "Paused"
    return stdout
end

cb1(stdout)

print(cb1())