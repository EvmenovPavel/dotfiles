local function get_context()
    local level   = 3

    local context = debug.getinfo(level)
    if not context then
        return true, nil
    end

    return false, context
end

local function remove_space(str, symbol)
    local str    = str
    local symbol = symbol or " "
    local index  = 0

    for i = 1, #str do
        local c = str:sub(i, i)
        if (c == symbol) then
        else
            index = i
            break
        end
    end

    str = str:sub(index, #str)

    for i = #str, 1, -1 do
        local c = str:sub(i, i)
        if (c == symbol) then
        else
            index = i
            break
        end
    end

    str = str:sub(1, index)

    return str
end

awesome.connect_signal(
        "debug::error",
        function(err, t1, t2, t3)

            local context_msg  = ""
            local err, context = get_context()
            if (err == true) then
            else
                context_msg = string.format("\n%s: : In function '%s'\n%s:%s",
                                            context.source,
                                            context.name,
                                            context.source,
                                            context.linedefined)
            end

            naughty.notify({
                               preset = preset,
                               title  = title,
                               text   = err
                           })

            local _, j = string.find(err, ".lua:")

            for i = j, #err do
                local c = err:sub(i, i)
                if (c == " ") then
                    local source_linedefined = string.sub(err, 1, i)
                    local msg                = string.sub(err, i, #err)

                    source_linedefined       = remove_space(source_linedefined)
                    msg                      = remove_space(msg)

                    log:debug("msg_: " .. msg)

                    return
                end
            end
        end
)
awesome.connect_signal(
        "debug::error",
        function(err, t1, t2, t3)
            local msg_ = get_context()

            --naughty.notify({
            --                   preset = preset,
            --                   title  = title,
            --                   text   = err
            --               })

            local _, j = string.find(err, ".lua:")

            for i = j, #err do
                local c = err:sub(i, i)
                if (c == " ") then
                    local source_linedefined = string.sub(err, 1, i)
                    local msg                = string.sub(err, i, #err)

                    source_linedefined       = wmapi:remove_space(source_linedefined)
                    msg                      = wmapi:remove_space(msg)

                    log:debug("source: " .. source_linedefined)
                    log:debug("msg: " .. msg)

                    return
                end
            end
        end
)

awesome.connect_signal(
        "debug::deprecation",
        function(msg, see, args)
            log:debug("debug::deprecation")
        end
)

awesome.connect_signal(
        "debug::index::miss",
        function(err)
            log:debug("debug::index::miss")
        end
)

awesome.connect_signal(
        "debug::newindex::miss",
        function(err)
            log:debug("debug::newindex::miss")
        end
)