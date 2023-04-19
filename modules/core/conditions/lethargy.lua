local Condition = require("core.condition")

local Lethargy = Condition:extend()
Lethargy.duration = 1000
Lethargy.name = "lethargy"

<<<<<<< HEAD
Lethargy:onAction(
   actions.Move,
   function(self, level, actor, action) action.time = action.time * 4 end
)
=======
Lethargy:onAction(actions.Move, function(self, level, actor, action)
	action.time = action.time * 4
end)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Lethargy
