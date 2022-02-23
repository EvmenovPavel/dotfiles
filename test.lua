local test = {}

local t    = 0

function test:set(input)
    t = input
end

function test:get()
    return t
end

local function init(...)
    return test
end

--return logging
return setmetatable(test, { __call = function(_, ...)
    return init(...)
end })
