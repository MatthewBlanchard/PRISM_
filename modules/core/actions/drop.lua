local Action = require("core.action")
local Vector2 = require("math.vector")

local Drop = Action:extend()
Drop.name = "drop"
Drop.targets = { targets.Item }

<<<<<<< HEAD
function Drop:perform(level) level:moveActor(self.targetActors[1], self.owner.position) end
=======
function Drop:perform(level)
	level:moveActor(self.targetActors[1], self.owner.position)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Drop
