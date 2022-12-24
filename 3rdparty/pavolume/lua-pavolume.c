#include <lauxlib.h>
#include <luainc.h>

static int printMessage(lua_State* lua)
{
    assert(lua_isstring(lua, 1));

    const char* msg = lua_tostring(lua, 1);

    // debug output
    cout << "script: " << msg << endl;
    return 0;
}

void test()
{
    int iErr = 0;
    lua_State* lua = lua_open();  // Open Lua
    luaopen_io(lua);              // Load io library
    if ((iErr = luaL_loadfile(lua, "test.lua")) == 0)
    {
        // Call main...
        if ((iErr = lua_pcall(lua, 0, LUA_MULTRET, 0)) == 0)
        {
            // Push the function name onto the stack
            lua_pushstring(lua, "helloWorld");
            // Function is located in the Global Table
            lua_gettable(lua, LUA_GLOBALSINDEX);
            lua_pcall(lua, 0, 0, 0);
        }
    }
    lua_close(lua);
}