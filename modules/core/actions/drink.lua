local Action = require "core.action"
local Consume = require "modules.core.actions.consume"

local Drink = Consume:extend()
Drink.name = "eat"
Drink.targets = {targets.Item}

function Drink:perform(level)
  Consume.perform(self, level)
end

return Drink
