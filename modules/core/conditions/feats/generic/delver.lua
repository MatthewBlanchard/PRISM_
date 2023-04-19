local Condition = require("core.condition")

local Delver = Condition:extend()
Delver.name = "Know It All"
Delver.description = "You always know the location of the exit. I bet you're fun at parties."

<<<<<<< HEAD
Delver:onScry(function(self, level, actor) return { level:getActorByType(actors.Stairs) } end)
=======
Delver:onScry(function(self, level, actor)
	return { level:getActorByType(actors.Stairs) }
end)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Delver
