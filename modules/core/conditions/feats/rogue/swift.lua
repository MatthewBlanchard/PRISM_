local Condition = require("core.condition")

local Swift = Condition:extend()
Swift.name = "Elusive Prey"
Swift.description = "When below half health you move 25% faster and can't be slowed down."

Swift:setTime(actions.Move, function(self, level, actor, action)
<<<<<<< HEAD
   if actor:getHP() <= actor:getMaxHP() / 2 then action.time = math.min(action.time, 75) end
=======
	if actor:getHP() <= actor:getMaxHP() / 2 then
		action.time = math.min(action.time, 75)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end)

return Swift
