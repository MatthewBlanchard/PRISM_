local Component = require("core.component")

local Drinkable = Component:extend()
Drinkable.name = "Drinkable"

Drinkable.requirements = {
<<<<<<< HEAD
   components.Item,
   components.Usable,
}

function Drinkable:__new(options)
   assert(options.drink:is(actions.Drink))
   self._drink = options.drink
end

function Drinkable:initialize(actor) actor:addUseAction(self._drink) end
=======
	components.Item,
	components.Usable,
}

function Drinkable:__new(options)
	assert(options.drink:is(actions.Drink))
	self._drink = options.drink
end

function Drinkable:initialize(actor)
	actor:addUseAction(self._drink)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Drinkable
