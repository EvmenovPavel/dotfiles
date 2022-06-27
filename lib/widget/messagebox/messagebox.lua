local naughty = require("lib.naughty")

--local ButtonRole     = {
--    InvalidRole     = -1,
--    AcceptRole      = 0,
--    RejectRole      = 1,
--    DestructiveRole = 2,
--    ActionRole      = 3,
--    HelpRole        = 4,
--    YesRole         = 5,
--    NoRole          = 6,
--    ResetRole       = 7,
--    ApplyRole       = 8,
--    NRoles          = 9
--};
--
--local StandardButton = {
--    NoButton        = 0x00000000,
--    Ok              = 0x00000400,
--    Save            = 0x00000800,
--    SaveAll         = 0x00001000,
--    Open            = 0x00002000,
--    Yes             = 0x00004000,
--    YesToAll        = 0x00008000,
--    No              = 0x00010000,
--    NoToAll         = 0x00020000,
--    Abort           = 0x00040000,
--    Retry           = 0x00080000,
--    Ignore          = 0x00100000,
--    Close           = 0x00200000,
--    Cancel          = 0x00400000,
--    Discard         = 0x00800000,
--    Help            = 0x01000000,
--    Apply           = 0x02000000,
--    Reset           = 0x04000000,
--    RestoreDefaults = 0x08000000,
--    FirstButton     = 0x00000400, -- Ok
--    LastButton      = 0x08000000, -- RestoreDefaults
--
--    YesAll          = 0x00008000, -- YesToAll
--    NoAll           = 0x00020000, -- NoToAll,
--
--    Default         = 0x00000100,
--    Escape          = 0x00000200,
--    FlagMask        = 0x00000300,
--    ButtonMask      = 0x00000300, -- FlagMask
--};

local function question(title, text)
    naughty.notify({
                       title = title,
                       text  = text,
                   })
end

local function information(title, text, ...)
    naughty.notify({
                       title   = title,
                       text    = text,

                       actions = {
                           ["Accept1"] = function()
                               naughty.notify({
                                                  title = "title",
                                                  text  = "text 1",
                                              })
                           end,
                           ["Accept2"] = function()
                               naughty.notify({
                                                  title = "title",
                                                  text  = "text 2",
                                              })
                           end
                       },
                   })
end

local function warning(title, text, ...)
    for i = 1, select("#", ...) do
        local action = select(i, ...)
        if action then
            local name     = action.name or "Action"
            local callback = action.callback or function()
                log:error()
            end
        end
    end

    local notification
    notification = naughty.notify({
                                      title   = title,
                                      text    = text,
                                      actions = {
                                          ["Accept"] = function()
                                              naughty.notify({
                                                                 title = "title",
                                                                 text  = "text",
                                                             })

                                              naughty.destroy(notification)
                                          end
                                      },
                                  })
end

local function critical(title, text, ...)
    --local preset        = args.preset or naughty.config.presets.info

    --local timeout       = args.timeout or preset.timeout
    --local hover_timeout = args.hover_timeout or preset.hover_timeout

    --local icon          = args.icon or nil

    --local title         = args.title or preset.title
    --local text          = args.text or preset.text

    --if not notification.panel_notification.visible then
    naughty.notify({
                       --preset        = preset,

                       --icon          = icon,
                       title = title,
                       text  = text,

                       --timeout       = timeout,
                       --hover_timeout = hover_timeout,
                   })
end

local function about(title, text)
    --local preset        = args.preset or naughty.config.presets.info

    --local timeout       = args.timeout or preset.timeout
    --local hover_timeout = args.hover_timeout or preset.hover_timeout

    --local icon          = args.icon or nil

    --local title         = args.title or preset.title
    --local text          = args.text or preset.text

    --if not notification.panel_notification.visible then
    naughty.notify({
                       --preset        = preset,

                       --icon          = icon,
                       title = title,
                       text  = text,

                       --timeout       = timeout,
                       --hover_timeout = hover_timeout,
                   })
end

local messagebox = {}

function messagebox:init()
    local ret = {}

    --function ret:custom(title, text, ...)
    --    question(title, text, ...)
    --end

    function ret:question(title, text)
        --question(title, text, ...)
    end

    function ret:information(title, text)
        information(title, text)
    end

    function ret:warning(title, text, ...)
        --warning(title, text, ...)
    end

    function ret:critical(title, text, ...)
        --critical(title, text, ...)
    end

    function ret:about(title, text, ...)
        --about(title, text, ...)
    end

    return ret
end

return messagebox
