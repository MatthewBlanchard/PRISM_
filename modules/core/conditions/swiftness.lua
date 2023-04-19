local Condition = require("core.condition")

local Swiftness = Condition:extend()
Swiftness.name = "Swiftness"
Swiftness.description = "Your actions take 25% less time."

<<<<<<< HEAD
Swiftness:onAction(
   actions.Move,
   function(self, level, actor, action) action.time = action.time * 0.75 end
)
=======
Swiftness:onAction(actions.Move, function(self, level, actor, action)
	action.time = action.time * 0.75
end)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Swiftness
