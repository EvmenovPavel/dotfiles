--local api  = require('telegram-bot-lua.core').configure('1584165136:AAGjQXrPaFByxbPKh4fWstDVP7a96fm7DWU')
--local json = require('dkjson')
--
--function api.on_callback_query(callback_query)
--    api.answer_callback_query(
--            callback_query.id,
--            json.encode(callback_query.from)
--    )
--end
---- https://api.telegram.org/bot<TOKEN>/sendMessage?chat_id=123&text=test&reply_markup={"keyboard": [["Button"]]}
---- {"keyboard":[["Yes","No"]],"resize_keyboard":false,"one_time_keyboard":false,"selective":false}
--
--local keyboard = { ['keyboard'] = {
--    ["button"] = "Yes",
--    ["button"] = "No",
--},
--                   ["resize_keyboard"] = true,
--                   ["one_time_keyboard"] = false,
--                   ["selective"] = false
--}
--
--function api.on_message(message)
--    print("on_message > message:", message.text)
--
--    api.send_message(
--            message.chat.id,
--            'TEST',
--            nil,
--            true,
--            false,
--            nil,
--            --nil
--            keyboard
--    )
--end
--
--api.run()

--
--local list = {}
--
--list["1"]  = 123
--list[2]    = "asdas"
--list[3]    = "table"
--
----print(list["1"])
----print(list[2])
--
--local function test(index)
--    if not (index == 5) then
--        return test(index + 1)
--    end
--
--    return index
--end
--
--print(test(1))
--
--local max = (4 > 5) and 1 or 2
--print(max)

--local private     = {}
--
--private.ellipsize = "start"
--
--local function ellipsize(ellipsize)
--    if type(ellipsize) == "string" then
--        if ellipsize == "start" or ellipsize == "middle" or ellipsize == "end" then
--            private.ellipsize = ellipsize
--            return private.ellipsize
--        end
--    end
--
--    local ellipsize = {}
--
--    function ellipsize:start()
--        private.ellipsize = "start"
--    end
--    function ellipsize:middle()
--        private.ellipsize = "middle"
--    end
--    function ellipsize:the_end()
--        private.ellipsize = "end"
--    end
--
--    return ellipsize
--end
--
--print(private.ellipsize)
--ellipsize():middle()
--print(private.ellipsize)
--ellipsize("end")
--print(private.ellipsize)

--local function run(self)
--    print(self.text) -- HELLO
--end
--
--local promptbox = {}
--
--promptbox.text  = "HELLO"
--promptbox.run   = run
--
--promptbox:run()

local test = nil

local i = 0

while (not test) do
    i = i + 1

    if (i == 100) then
        test = "test"
    end
end

print("test")