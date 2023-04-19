local Component = require("core.component")

local Edible = Component:extend()
Edible.name = "edible"

Edible.requirements = {
<<<<<<< HEAD
   components.Item,
   components.Usable,
}

function Edible:__new(options) self.nutrition = options.nutrition end

function Edible:initialize(actor) actor:addUseAction(actions.Eat) end
=======
	components.Item,
	components.Usable,
}

function Edible:__new(options)
	self.nutrition = options.nutrition
end

function Edible:initialize(actor)
	actor:addUseAction(actions.Eat)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Edible
