local event                                = {}

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

event.key                                  = {}
event.key.mod                              = "Mod4"
event.key.win                              = event.key.mod
event.key.num_lock                         = "Mod2"
event.key.enter                            = "Return"
event.key.fn                               = "xev"
event.key.altL                             = "Mod1"
event.key.alt_L                            = "Alt_L"
event.key.altR                             = "Mod1"
event.key.alt_R                            = "Alt_L"
event.key.ctrl                             = "Control"
event.key.space                            = "space"
event.key.shift                            = "Shift"
event.key.esc                              = "Escape"
event.key.tab                              = "Tab"
event.key.print                            = "Print"
event.key.delete                           = "Delete"

event.key.bracket_left                     = "["
event.key.bracket_right                    = "]"

event.key.left                             = "Left"
event.key.right                            = "Right"
event.key.down                             = "Down"
event.key.up                               = "Up"

event.key.XF86Search                       = "XF86Search"

event.key.system                           = {}
event.key.system.poweroff                  = "XF86PowerOff"
event.key.system.calculator                = "XF86Calculator"
event.key.system.sleep                     = "XF86Sleep"
event.key.system.wakeUp                    = "XF86WakeUp"
event.key.system.battery                   = "XF86Battery"

-- ALSA volume control
-- Audio
event.key.audio                            = {}
event.key.audio.XF86AudioPlay              = "XF86AudioPlay"
event.key.audio.XF86AudioStop              = "XF86AudioStop"
event.key.audio.XF86AudioMute              = "XF86AudioMute"
event.key.audio.XF86AudioLowerVolume       = "XF86AudioLowerVolume"
event.key.audio.XF86AudioRaiseVolume       = "XF86AudioRaiseVolume"
event.key.audio.XF86AudioNext              = "XF86AudioNext"
event.key.audio.XF86AudioPrev              = "XF86AudioPrev"

-- Brightness
event.key.brightness                       = {}
event.key.brightness.XF86MonBrightnessUp   = "XF86MonBrightnessUp"
event.key.brightness.XF86MonBrightnessDown = "XF86MonBrightnessDown"


--event.key.volumeKPEqual            = "KP_Equal"
--event.key.volumePlusminus          = "plusminus"
--event.key.volumePauseBreak         = "Pause Break"
--event.key.volumeLaunchA            = "XF86LaunchA"
--event.key.volumeKPDecimal          = "KP_Decimal"

event.key.a                                = "a"
event.key.b                                = "b"
event.key.c                                = "c"
event.key.d                                = "d"
event.key.e                                = "e"
event.key.f                                = "f"
event.key.g                                = "g"
event.key.h                                = "h"
event.key.i                                = "i"
event.key.j                                = "j"
event.key.k                                = "k"
event.key.l                                = "l"
event.key.m                                = "m"
event.key.n                                = "n"
event.key.o                                = "o"
event.key.p                                = "p"
event.key.q                                = "q"
event.key.r                                = "r"
event.key.s                                = "s"
event.key.t                                = "t"
event.key.u                                = "u"
event.key.v                                = "v"
event.key.w                                = "w"
event.key.x                                = "x"
event.key.y                                = "y"
event.key.z                                = "z"

event.key.F1                               = "F1"
event.key.F2                               = "F2"
event.key.F3                               = "F3"
event.key.F4                               = "F4"
event.key.F5                               = "F5"
event.key.F6                               = "F6"
event.key.F7                               = "F7"
event.key.F8                               = "F8"
event.key.F9                               = "F9"
event.key.F10                              = "F10"
event.key.F11                              = "F11"
event.key.F12                              = "F12"

event.mouse                                = {}
event.mouse.button_click_left              = 1
event.mouse.button_click_right             = 3
event.mouse.button_click_scroll            = 5
event.mouse.button_click_scroll_up         = 2
event.mouse.button_click_scroll_down       = 4


--https://awesomewm.org/doc/api/libraries/mouse.html
event.signals                              = {}
event.signals.mouse                        = {}
event.signals.mouse.enter                  = "mouse::enter"
event.signals.mouse.leave                  = "mouse::leave"
event.signals.mouse.press                  = "mouse::press"
event.signals.mouse.release                = "mouse::release"
event.signals.mouse.move                   = "mouse::move"

event.signals.button                       = {}
-- release срабатывает, когда нажатие мыши отпущено
event.signals.button.release               = "button::release"
event.signals.button.press                 = "button::press"

event.signals.widget                       = {}
event.signals.widget.layout_changed        = "widget::layout_changed"
event.signals.widget.redraw_needed         = "widget::redraw_needed"
-- "XF86Launch1" ???

event.key.test                             = {}
event.key.test.XF86RFKill                  = "XF86RFKill"
event.key.test.XF86Search                  = "XF86Search"
event.key.test.Super_L                     = "Super_L"
event.key.test.h                           = "h"
event.key.test.XF86Favorites               = "XF86Favorites"

--state 0x50, keycode 43 (keysym 0x68, h), same_screen YES,
--state 0x50, keycode 133 (keysym 0xffeb, Super_L), same_screen YES,
--state 0x10, keycode 43 (keysym 0x68, h), same_screen YES,

return event