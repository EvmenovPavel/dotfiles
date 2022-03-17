--local key        = keygrabber

local keygrabber       = {
    keygrabber = keygrabber
}

keygrabber._keygrabber = function(mod, keys, event)
    if keys == self.key_switch and event == "press" then
        self:toggle()
    elseif keys == self.mod_key and event == "release" then
        self:close()
    end
end

function keygrabber:toggle()

end

function keygrabber:close()
    self.keygrabber.stop(self._keygrabber)
    --keygrabber.stop()
    self.is_active = false
    --self.wibox.visible = false
end

function keygrabber:open()
    if not self.is_active then
        self.keygrabber.run(self._keygrabber)
        self.is_active = true
        --self.wibox.visible = true
    end
end

function keygrabber:hide()
    self:close()
end

function keygrabber:toggle(args)
    if self.wibox.visible then
        self:close()
    else
        self:open(args)
    end
end

function keygrabber:create()
    self.mod_key    = capi.event.key.esc
    self.key_switch = capi.event.key.tab

    self.is_active  = false

end

return keygrabber