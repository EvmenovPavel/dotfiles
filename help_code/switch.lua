local switch = function(param, case_table)
    local case = case_table[param]

    if case then
        return case()
    end

    local def = case_table['default']

    return def and def() or nil
end

local a      = 110

switch(a, {
    [1] = function()
        -- for case 1
        print("Case 1.")
    end,
    [2] = function()
        -- for case 2
        print("Case 2.")
    end,
    [3] = function()
        -- for case 3
        print("Case 3.")
    end
})
