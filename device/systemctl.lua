local systemctl    = {}

-- Shut down and power-off the system
systemctl.poweroff = "systemctl poweroff"
-- Shut down and reboot the system
systemctl.reboot   = "systemctl reboot"
-- Suspend the system
systemctl.suspend  = "systemctl suspend"

return systemctl