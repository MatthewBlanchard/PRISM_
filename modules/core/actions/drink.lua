local Action = require("core.action")
local Consume = require("modules.core.actions.consume")

local Drink = Consume:extend()
Drink.name = "drink"
Drink.targets = { targets.Item }

<<<<<<< HEAD
function Drink:perform(level) Consume.perform(self, level) end
=======
function Drink:perform(level)
	Consume.perform(self, level)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Drink
