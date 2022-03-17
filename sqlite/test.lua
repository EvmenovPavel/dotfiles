-- Using LuaSQL for sqlite3 DB handling.

local luasql = require('luasql.sqlite3')

local env    = assert(luasql.sqlite3()) -- create the context
local conn   = assert(env:connect("test.sqlite")) -- connect to the DB

-- Do some queries.
assert(conn:execute("CREATE TABLE IF NOT EXISTS tbl1(one varchar(10), two smallint)"))
assert(conn:execute("INSERT INTO tbl1 VALUES('hello!', 10)"))
assert(conn:execute("INSERT INTO tbl1 VALUES('goodbye', 20)"))

local cursor = assert(conn:execute("SELECT * FROM tbl1 WHERE one LIKE 'good%'"))

local row    = {}
while cursor:fetch(row) do
    -- print all elements
    print(table.concat(row, ' | '))
end

cursor:close() -- close the record fetching handler
conn:close()  -- close the connection to the DB
env:close() -- release the context