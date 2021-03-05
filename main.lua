--local sqlite3 = require("luasql.sqlite3")
----local env      = assert(sqlite3.sqlite3())
----local database = assert(env:connect("db.sqlite3"))
--
--local env = sqlite3.sqlite3()
--
--local database = env:connect("db.sqlite3")
--
--local sqlite = {}
--
--function sqlite:create()
--
--end
--
--function sqlite:insert(name_table)
--    assert(conn:execute("create table if not exists tbl1(one varchar(10), two smallint)"))
--    assert(conn:execute("insert into tbl1 values('hello!',10)"))
--    assert(conn:execute("insert into tbl1 values('goodbye',20)"))
--
----    assert(database:execute(
----            string.format([[INSERT INTO .. name_table .. (name, path) VALUES ('%s', '%s')]], 'asdasd', '123123')
----    ))
--end
--
--function sqlite:show(name_table, con)
--    local cur = assert(con:execute("SELECT * FROM " .. name_table))
--
--    local row = cur:fetch({}, "a")
--    while row do
--        print(string.format("Name: %s", row.name))
--        print(string.format("Path: %s", row.path))
--        row = cur:fetch(row, "a")
--    end
--
--    cur:close()
--end
--
--sqlite:show("apps_run", database)
--
--database:close()
--env:close()
--
--
--function test(...)
--    for i = 1, select('#', ...) do
--        print(tostring(select(i, ...)))
--    end
--end
--
--test("asdasd", "11")

local json = require("module.json.json")

local t    = {
    { '{x', '1}', },
    '{x : hello}',
    "{'x' : 1}",
    '{"x" : nil}',
    '{"x" : 0x10}',
    '{"x" : 001}',
    '{"x" : .1}',
    '{"x" : 1, }',
    '[1, 2, 3, ]',
}

local str  = json.encode(t)
print(str)

for _, i in ipairs(json.decode(str)) do
    if type(i) == "table" then
        print("YES")
    end
    print(i)
end