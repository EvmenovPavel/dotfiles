-- automatically generated file. Do not edit (see /usr/share/doc/menu/html)

local awesome                                                = awesome

Debian_menu                                                  = {}

Debian_menu["Debian_Applications_Accessibility"]             = {
    { "Xmag", "xmag" },
}
Debian_menu["Debian_Applications_Editors"]                   = {
    { "Xedit", "xedit" },
}
Debian_menu["Debian_Applications_Graphics"]                  = {
    { "xcb", "/usr/bin/xcb" },
    { "X Window Snapshot", "xwd | xwud" },
}
Debian_menu["Debian_Applications_Network_Communication"]     = {
    { "Telnet", "x-terminal-emulator -e " .. "/usr/bin/telnet.netkit" },
    { "Xbiff", "xbiff" },
}
Debian_menu["Debian_Applications_Network_File_Transfer"]     = {
    { "Deluge", "/usr/bin/deluge", },
}
Debian_menu["Debian_Applications_Network_Web_Browsing"]      = {
    { "Google Chrome", "/opt/google/chrome/google-chrome", "/opt/google/chrome/product_logo_32.xpm" },
    { "Lynx", "x-terminal-emulator -e " .. "lynx" },
    { "Opera", "/usr/bin/opera", "/usr/share/pixmaps/opera.xpm" },
    { "Yandex Browser", "/opt/yandex/browser/yandex-browser", "/opt/yandex/browser/product_logo_32.xpm" },
}
Debian_menu["Debian_Applications_Network"]                   = {
    { "Communication", Debian_menu["Debian_Applications_Network_Communication"] },
    { "File Transfer", Debian_menu["Debian_Applications_Network_File_Transfer"] },
    { "Web Browsing", Debian_menu["Debian_Applications_Network_Web_Browsing"] },
}
Debian_menu["Debian_Applications_Programming"]               = {
    { "Monodoc (http)", "x-terminal-emulator -e " .. "/usr/bin/monodoc-http", "/usr/share/pixmaps/monodoc.xpm" },
    { "Tclsh8.6", "x-terminal-emulator -e " .. "/usr/bin/tclsh8.6" },
    { "TkCVS", "/usr/bin/tkcvs", "/usr/share/pixmaps/tkcvs.xpm" },
    { "TkWish8.6", "x-terminal-emulator -e /usr/bin/wish8.6" },
}
Debian_menu["Debian_Applications_Science_Mathematics"]       = {
    { "Bc", "x-terminal-emulator -e " .. "/usr/bin/bc" },
    { "Dc", "x-terminal-emulator -e " .. "/usr/bin/dc" },
    { "Xcalc", "xcalc" },
}
Debian_menu["Debian_Applications_Science"]                   = {
    { "Mathematics", Debian_menu["Debian_Applications_Science_Mathematics"] },
}
Debian_menu["Debian_Applications_Shells"]                    = {
    { "Bash", "x-terminal-emulator -e " .. "/bin/bash --login" },
    { "Dash", "x-terminal-emulator -e " .. "/bin/dash -i" },
    { "Sh", "x-terminal-emulator -e " .. "/bin/sh --login" },
}
Debian_menu["Debian_Applications_System_Administration"]     = {
    { "Editres", "editres" },
    { "Xclipboard", "xclipboard" },
    { "Xfontsel", "xfontsel" },
    { "Xkill", "xkill" },
    { "Xrefresh", "xrefresh" },
}
Debian_menu["Debian_Applications_System_Hardware"]           = {
    { "Xvidtune", "xvidtune" },
}
Debian_menu["Debian_Applications_System_Monitoring"]         = {
    { "Pstree", "x-terminal-emulator -e " .. "/usr/bin/pstree.x11", "/usr/share/pixmaps/pstree16.xpm" },
    { "Top", "x-terminal-emulator -e " .. "/usr/bin/top" },
    { "Xconsole", "xconsole -file /dev/xconsole" },
    { "Xev", "x-terminal-emulator -e xev" },
    { "Xload", "xload" },
}
Debian_menu["Debian_Applications_System_Package_Management"] = {
    { "Synaptic Package Manager", "x-terminal-emulator -e synaptic-pkexec", "/usr/share/synaptic/pixmaps/synaptic_32x32.xpm" },
}
Debian_menu["Debian_Applications_System"]                    = {
    { "Administration", Debian_menu["Debian_Applications_System_Administration"] },
    { "Hardware", Debian_menu["Debian_Applications_System_Hardware"] },
    { "Monitoring", Debian_menu["Debian_Applications_System_Monitoring"] },
    { "Package Management", Debian_menu["Debian_Applications_System_Package_Management"] },
}
Debian_menu["Debian_Applications_Viewers"]                   = {
    { "Xditview", "xditview" },
}
Debian_menu["Debian_Applications"]                           = {
    { "Accessibility", Debian_menu["Debian_Applications_Accessibility"] },
    { "Editors", Debian_menu["Debian_Applications_Editors"] },
    { "Graphics", Debian_menu["Debian_Applications_Graphics"] },
    { "Network", Debian_menu["Debian_Applications_Network"] },
    { "Programming", Debian_menu["Debian_Applications_Programming"] },
    { "Science", Debian_menu["Debian_Applications_Science"] },
    { "Shells", Debian_menu["Debian_Applications_Shells"] },
    { "System", Debian_menu["Debian_Applications_System"] },
    { "Viewers", Debian_menu["Debian_Applications_Viewers"] },
}
Debian_menu["Debian_CrossOver"]                              = {
    { "CrossOver", "/opt/cxoffice/bin/crossover", "/opt/cxoffice/share/icons/32x32/crossover.png" },
    { "Uninstall CrossOver", "/opt/cxoffice/bin/cxuninstall", "/opt/cxoffice/share/icons/32x32/cxuninstall.png" },
}
Debian_menu["Debian_Games_Toys"]                             = {
    { "Oclock", "oclock" },
    { "Xclock (analog)", "xclock -analog" },
    { "Xclock (digital)", "xclock -digital -update 1" },
    { "Xeyes", "xeyes" },
    { "Xlogo", "xlogo" },
}
Debian_menu["Debian_Games"]                                  = {
    { "Toys", Debian_menu["Debian_Games_Toys"] },
}
Debian_menu["Debian_Help"]                                   = {
    { "Xman", "xman" },
}
Debian_menu["Debian_Window_Managers"]                        = {
    { "awesome", function() awesome.exec("/usr/bin/awesome") end, "/usr/share/pixmaps/awesome.xpm" },
}
Debian_menu["Debian_Windows_Applications_4K_Stogram"]        = {
    { "4K Stogram", "\"/home/be3yh4uk/.cxoffice/4KStogram/desktopdata/cxmenu/StartMenu.C^5E3A_ProgramData_Microsoft_Windows_Start^2BMenu/Programs/4K+Stogram/4K+Stogram.lnk\"", "/home/be3yh4uk/.cxoffice/4KStogram/windata/cxmenu/icons/hicolor/32x32/apps/04CC_4kstogram.0.png" },
    { "Uninstall 4K Stogram", "\"/home/be3yh4uk/.cxoffice/4KStogram/desktopdata/cxmenu/StartMenu.C^5E3A_ProgramData_Microsoft_Windows_Start^2BMenu/Programs/4K+Stogram/Uninstall+4K+Stogram.lnk\"", "/home/be3yh4uk/.cxoffice/4KStogram/windata/cxmenu/icons/hicolor/32x32/apps/2BBC_shell32.31.png" },
}
Debian_menu["Debian_Windows_Applications"]                   = {
    { "4K Stogram", Debian_menu["Debian_Windows_Applications_4K_Stogram"] },
}
Debian_menu["Debian"]                                        = {
    { "Applications", Debian_menu["Debian_Applications"] },
    { "CrossOver", Debian_menu["Debian_CrossOver"] },
    { "Games", Debian_menu["Debian_Games"] },
    { "Help", Debian_menu["Debian_Help"] },
    { "Window Managers", Debian_menu["Debian_Window_Managers"] },
    { "Windows Applications", Debian_menu["Debian_Windows_Applications"] },
}

debian                                                       = { menu = { Debian_menu = Debian_menu } }
return debian