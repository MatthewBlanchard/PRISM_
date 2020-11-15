local Component = require "component"
local Condition = require "condition"

local Cost = Component:extend()
Cost.name = "Cost"
Cost.requirements = {components.Item}

local dummy = {}
function Cost:__new(options)
  options = options or dummy
  self.cost = options.cost
  self.rarity = options.rarity or "common"
end

function Cost:initialize(actor)
  print("rarity ", self.rarity)
  print("dood")
  actor.rarity = self.rarity
  actor.cost = self.cost or Loot.generateBasePrice(actor)
  print(actor.name, actor.cost)
end

return Cost
