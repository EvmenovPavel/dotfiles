--https://awesomewm.org/doc/api/libraries/mouse.html
local signals                 = {}

signals.mouse                 = {}
signals.mouse.enter           = "mouse::enter"
signals.mouse.leave           = "mouse::leave"
signals.mouse.press           = "mouse::press"
signals.mouse.release         = "mouse::release"
signals.mouse.move            = "mouse::move"

signals.button                = {}
-- release срабатывает, когда нажатие мыши отпущено
signals.button.release        = "button::release"
signals.button.press          = "button::press"

signals.widget                = {}
signals.widget.layout_changed = "widget::layout_changed"
signals.widget.redraw_needed  = "widget::redraw_needed"
-- "XF86Launch1" ???

return signals