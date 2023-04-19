local Component = require("core.component")

local Pushable = Component:extend()
Pushable.name = "Pushable"

Pushable.requirements = {
<<<<<<< HEAD
   components.Usable,
}

function Pushable:initialize(actor) actor:addUseAction(actions.Push) end
=======
	components.Usable,
}

function Pushable:initialize(actor)
	actor:addUseAction(actions.Push)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Pushable
