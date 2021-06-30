--local LIP    = require("lib.lip.LIP");
--
--
---- Data saving
--
--
---- Data loading
----local data = LIP.load('savedata.ini');
--
----for _, it in pairs(data.wallpaper) do
----    print(it)
----end
--
--local lfs    = require("lfs")
--
--local config = {}
--
--function config:user()
--    local user = io.popen("getent passwd $USER | cut -d ':' -f 1 | cut -d ',' -f 1"):read()
--    return user
--end
--
--function config:create_dir(path, name_fir)
--    return not lfs.mkdir(path .. "/" .. name_fir) -- error = true
--end
--
--function config:create_file(path, name_file)
--    local file = io.open(string.format(path .. "/%s/config", name_file), "w")
--    file:close()
--end
--
--function config:save_config(path, data)
--    LIP:save(path .. "/config", data);
--end
--
--function config:create_config()
--    local root_path = os.getenv("HOME") .. "/.config/awesome/device"
--
--    local device    = self:user()
--
--    if (not self:create_dir(root_path, device)) then
--        self:create_dir(root_path, device .. "/wallpaper")
--        self:create_file(root_path, device)
--    end
--
--    local data = {
--        screen = {
--            primary   = 2,
--            focused   = false,
--            wallpaper = {
--                "wallpaper_1.png",
--                "wallpaper_2.png",
--                "wallpaper_3.png",
--            },
--            font      = "",
--        },
--    }
--
--    self:save_config(data)
--end
--
--function config:read_config()
--
--end
--
--config:create_config()
--
----[[
--[window]
--[wallpaper]
--]]

function message(...)
    local date = os.date()
    local msg  = date

    for i = 1, select("#", ...) do
        msg = msg .. "\n\t" .. tostring(select(i, ...))
    end

    print(msg)
end

message("asdasd")