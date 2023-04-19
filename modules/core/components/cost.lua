local Component = require("core.component")

local Cost = Component:extend()
Cost.name = "Cost"
Cost.requirements = { components.Item }

local dummy = {}
function Cost:__new(options)
<<<<<<< HEAD
   options = options or dummy
   self.rarity = options.rarity or "common"
   self.tags = options.tags or {}
   self.cost = options.cost
end

function Cost:initialize(actor) self.cost = self.cost or Loot.generateBasePrice(actor) end
=======
	options = options or dummy
	self.rarity = options.rarity or "common"
	self.tags = options.tags or {}
	self.cost = options.cost
end

function Cost:initialize(actor)
	self.cost = self.cost or Loot.generateBasePrice(actor)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Cost
