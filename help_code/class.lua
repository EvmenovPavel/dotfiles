function extended (child, parent)
    setmetatable(child, { __index = parent })
end

function extend(parent)
    local child = {}
    setmetatable(child, { __index = parent })
    return child
end

local Person = {}
function Person:new(name)

    local private = {}
    private.age   = 18

    local public  = {}
    public.name   = name or "Вася"

    --это защищенный метод, его нельзя переопределить
    function public:getName()
        return "Person protected " .. self.name
    end

    --этот метод можно переопределить
    function Person:getName2()
        return "Person " .. self.name
    end

    setmetatable(public, self)

    self.__index = self;

    return public
end

--создадим класс, унаследованный от Person
local Woman = extend(Person)
--extended(Woman, Person)  --не забываем про эту функцию

--переопределим метод setName
function Woman:getName2()
    return "Woman " .. self.name
end

local masha = Woman:new()
print(masha:getName2())  --> Woman Вася

--вызываем метод родительского класса
print(Person.getName2(masha)) --> Person Вася
