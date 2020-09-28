-- >> xmodmap
-- xmodmap:  up to 4 keys per modifier, (keycodes in parentheses):
--
-- shift       Shift_L (0x32),  Shift_R (0x3e)
-- lock        Caps_Lock (0x42)
-- control     Control_L (0x25),  Control_R (0x69)
-- mod1        Alt_L (0x40),  Alt_R (0x6c),  Meta_L (0xcd)
-- mod2        Num_Lock (0x4d)
-- mod3
-- mod4        Super_L (0x85),  Super_R (0x86),  Super_L (0xce),  Hyper_L (0xcf)
-- mod5        ISO_Level3_Shift (0x5c),  Mode_switch (0xcb)

local key                            = {}

key                                  = {}
key.mod                              = "Mod4"
key.win                              = key.mod
key.num_lock                         = "mod2"
key.enter                            = "Return"
key.fn                               = "xev"
key.alt_L                            = "Mod1"
key.alt_R                            = "Mod1"
key.ctrl                             = "Control"
key.space                            = "space"
key.shift                            = "Shift"
key.esc                              = "Escape"
key.tab                              = "Tab"
key.print                            = "Print"
key.delete                           = "Delete"

key.bracket_left                     = "["
key.bracket_right                    = "]"

key.left                             = "Left"
key.right                            = "Right"
key.down                             = "Down"
key.up                               = "Up"

key.XF86Search                       = "XF86Search"

key.system                           = {}
key.system.poweroff                  = "XF86PowerOff"
key.system.calculator                = "XF86Calculator"
key.system.sleep                     = "XF86Sleep"
key.system.wakeUp                    = "XF86WakeUp"
key.system.battery                   = "XF86Battery"

-- ALSA volume control
-- Audio
key.audio                            = {}
key.audio.XF86AudioPlay              = "XF86AudioPlay"
key.audio.XF86AudioStop              = "XF86AudioStop"
key.audio.XF86AudioMute              = "XF86AudioMute"
key.audio.XF86AudioLowerVolume       = "XF86AudioLowerVolume"
key.audio.XF86AudioRaiseVolume       = "XF86AudioRaiseVolume"
key.audio.XF86AudioNext              = "XF86AudioNext"
key.audio.XF86AudioPrev              = "XF86AudioPrev"

-- Brightness
key.brightness                       = {}
key.brightness.XF86MonBrightnessUp   = "XF86MonBrightnessUp"
key.brightness.XF86MonBrightnessDown = "XF86MonBrightnessDown"


--key.volumeKPEqual            = "KP_Equal"
--key.volumePlusminus          = "plusminus"
--key.volumePauseBreak         = "Pause Break"
--key.volumeLaunchA            = "XF86LaunchA"
--key.volumeKPDecimal          = "KP_Decimal"

key.a                                = "a"
key.b                                = "b"
key.c                                = "c"
key.d                                = "d"
key.e                                = "e"
key.f                                = "f"
key.g                                = "g"
key.h                                = "h"
key.i                                = "i"
key.j                                = "j"
key.k                                = "k"
key.l                                = "l"
key.m                                = "m"
key.n                                = "n"
key.o                                = "o"
key.p                                = "p"
key.q                                = "q"
key.r                                = "r"
key.s                                = "s"
key.t                                = "t"
key.u                                = "u"
key.v                                = "v"
key.w                                = "w"
key.x                                = "x"
key.y                                = "y"
key.z                                = "z"

key.F1                               = "F1"
key.F2                               = "F2"
key.F3                               = "F3"
key.F4                               = "F4"
key.F5                               = "F5"
key.F6                               = "F6"
key.F7                               = "F7"
key.F8                               = "F8"
key.F9                               = "F9"
key.F10                              = "F10"
key.F11                              = "F11"
key.F12                              = "F12"

return key