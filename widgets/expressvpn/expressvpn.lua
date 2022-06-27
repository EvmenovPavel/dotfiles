--hp-envy-x360-15-ee0020nn@be3yh4uk:~$ expressvpn status
--A new version is available, download it from https://www.vlycgtx.com/latest#linux.
--
--Connected to Ukraine
--
--   - If your VPN connection unexpectedly drops, internet traffic will be blocked to protect your privacy.
--   - To disable Network Lock, disconnect ExpressVPN then type 'expressvpn preferences set network_lock off'.

--hp-envy-x360-15-ee0020nn@be3yh4uk:~$ expressvpn status
--A new version is available, download it from https://www.vlycgtx.com/latest#linux.
--
--Not connected

local expressvpn = {}

function expressvpn:state_to_number(line)
    if string.find(line, "Connected to") then
        return 1
    elseif string.find(line, "Not connected") then
        return 2
    end

    return 3
end

function expressvpn:notify_power(notify, line)
    local messagebox = wmapi:widget():messagebox()

    if notify == 1 then
        messagebox:information("ExpressVPN", line)
    elseif notify == 2 then
        messagebox:information("ExpressVPN", line)
    elseif notify == 3 then
        messagebox:information("ExpressVPN", "Error: " .. line)
    end
end

function expressvpn:init()
    local _private    = {}

    _private.notify   = 0
    _private.state    = 0
    _private.line     = ""

    local bash_upower = [[bash -c "expressvpn status"]]

    wmapi:watch(bash_upower, 1,
                function(stdout)
                    for line in stdout:gmatch("[^\r\n]+") do
                        _private.line  = line:gsub("^%s+", "")
                        _private.state = tonumber(self:state_to_number(line))
                    end

                    if _private.state == 1 and _private.notify ~= _private.state then
                        self:notify_power(_private.state, _private.line)

                    elseif _private.state == 2 and _private.notify ~= _private.state then
                        self:notify_power(_private.state, _private.line)

                    elseif _private.state == 3 and _private.notify ~= _private.state then
                        self:notify_power(_private.state, _private.line)

                    end

                    _private.notify = _private.state
                end)
end

return setmetatable(expressvpn, { __call = function(_, ...)
    return expressvpn:init(...)
end })
