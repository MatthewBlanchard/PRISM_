local Action = require "action"
local Consume = require "actions/consume"

local Drink = Consume:extend()
Drink.name = "drink"
Drink.targets = {targets.Item}

function Drink:perform(level)
  Consume.perform(self, level)
end

return Drink
