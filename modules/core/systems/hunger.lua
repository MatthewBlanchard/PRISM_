local System = require("core.system")

local Hunger = System:extend()
Hunger.name = "Hunger"

function Hunger:onTick(level, actor, action)
<<<<<<< HEAD
   for _, hunger_component in level:eachActor(components.Hunger) do
      hunger_component.satiation = hunger_component.satiation - 1
   end
=======
	for _, hunger_component in level:eachActor(components.Hunger) do
		hunger_component.satiation = hunger_component.satiation - 1
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Hunger
