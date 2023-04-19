local Component = require("core.component")

local Message = Component:extend()
Message.name = "message"

<<<<<<< HEAD
function Message:initialize(actor) self.messages = {} end

function Message:add(message) table.insert(self.messages, message) end
=======
function Message:initialize(actor)
	self.messages = {}
end

function Message:add(message)
	table.insert(self.messages, message)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Message
