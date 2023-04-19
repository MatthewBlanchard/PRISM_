local Condition = require("core.condition")

local Finesse = Condition:extend()
Finesse.name = "Fast Hands"
Finesse.description = "Your hands are dangerously fast. The faster your attack the more damage!"

<<<<<<< HEAD
Finesse:onAction(
   actions.Attack,
   function(self, level, actor, action)
      action.bonusDamage = math.min(5, math.max(0, 25 / action.speed) * 5)
   end
)
=======
Finesse:onAction(actions.Attack, function(self, level, actor, action)
	action.bonusDamage = math.min(5, math.max(0, 25 / action.speed) * 5)
end)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Finesse
