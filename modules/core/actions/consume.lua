local Action = require("core.action")
local Consume = Action:extend()
Consume.name = "eat"
Consume.targets = { targets.Item }

function Consume:perform(level)
<<<<<<< HEAD
   local consumable = self:getTarget(1)
   level:removeActor(consumable)
=======
	local consumable = self:getTarget(1)
	level:removeActor(consumable)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Consume
