local Component = require("core.component")

local Attacker = Component:extend()
Attacker.name = "Attacker"

Attacker.requirements = {
<<<<<<< HEAD
   components.Stats,
}

Attacker.actions = {
   actions.Attack,
   actions.Wield,
   actions.Unwield,
}

function Attacker:__new(options)
   self.defaultAttack = options.defaultAttack
   self.wielded = self.defaultAttack
=======
	components.Stats,
}

Attacker.actions = {
	actions.Attack,
	actions.Wield,
	actions.Unwield,
}

function Attacker:__new(options)
	self.defaultAttack = options.defaultAttack
	self.wielded = self.defaultAttack
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Attacker
