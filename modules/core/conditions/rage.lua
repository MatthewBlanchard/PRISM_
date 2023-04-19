local Condition = require("core.condition")

local Rage = Condition:extend()
Rage.name = "anger"
Rage.count = 0

Rage:setDuration(5000)

<<<<<<< HEAD
Rage:onAction(reactions.Die, function(self, level, actor, action) self.count = self.count + 1 end)

function Rage:getATK() return self.count * 2 end
=======
Rage:onAction(reactions.Die, function(self, level, actor, action)
	self.count = self.count + 1
end)

function Rage:getATK()
	return self.count * 2
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Rage
