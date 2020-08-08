---------------------------------------------------------------------------
--- Additional hotkeys for awful.hotkeys_widget
--
-- @author Yauheni Kirylau &lt;yawghen@gmail.com&gt;
-- @copyright 2014-2015 Yauheni Kirylau
-- @submodule awful.hotkeys_popup
---------------------------------------------------------------------------


local keys = {
    vim         = require("lib.awful.hotkeys_popup.keys.vim"),
    firefox     = require("lib.awful.hotkeys_popup.keys.firefox"),
    tmux        = require("lib.awful.hotkeys_popup.keys.tmux"),
    qutebrowser = require("lib.awful.hotkeys_popup.keys.qutebrowser"),
    termite     = require("lib.awful.hotkeys_popup.keys.termite"),
}
return keys

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
