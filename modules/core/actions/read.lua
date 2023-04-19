local Action = require("core.action")
local Consume = require("modules.core.actions.consume")

local Read = Consume:extend()
Read.name = "eat"
Read.targets = { targets.Item }

<<<<<<< HEAD
function Read:perform(level) Consume.perform(self, level) end
=======
function Read:perform(level)
	Consume.perform(self, level)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Read
