local Component = require("core.component")

local Progression = Component:extend()
Progression.name = "Progression"
Progression.requirements = { components.Stats }

Progression.actions = { actions.Level }

function Progression:initialize(actor)
<<<<<<< HEAD
   self.level = 0
   self.classAbility = nil
=======
	self.level = 0
	self.classAbility = nil
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Progression
