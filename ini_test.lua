local LIP  = require("lib.lip.LIP");

local data = {
    sound  = {
        left  = 70,
        right = 80,
    },
    screen = {
        width   = 960,
        height  = 544,
        caption = 'Window\'s caption',
        focused = true,
    },
};

-- Data saving
LIP.save('savedata.ini', data);


-- Data loading
local data = LIP.load('savedata.ini');

print(data.sound.right); --> 80
print(data.screen.caption); --> Window's caption
print(data.screen.focused); --> true