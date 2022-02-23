local rules = {}

local function init(clientkeys, buttonkeys)
    return {
        require("rules.rules")(clientkeys, buttonkeys),

        -- Firefox
        require("rules.pictureinpicture")(),

        -- Maximized
        require("rules.maximized")(),

        -- CopyQ
        require("rules.copyq")(),

        -- UE4Editor
        require("rules.ue4editor")(),
    }
end

return setmetatable(rules, { __call = function(_, ...)
    return init(...)
end })