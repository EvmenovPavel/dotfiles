local power  = 0
local notify = 0

power        = 3

for i = 1, 10 do
    if power == 1 and notify ~= 1 then
        notify = 1
        print("1")
    elseif power == 2 and notify ~= 2 then
        notify = 2
        print("2")
    elseif power == 3 and notify ~= 3 then
        notify = 3
        print("3")
    end
end