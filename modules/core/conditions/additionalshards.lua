local Condition = require("core.condition")

local AdditionalShards = Condition:extend()
AdditionalShards.name = "lethargy"

function AdditionalShards:__new(options)
<<<<<<< HEAD
   Condition.__new(self)
   self.chance = options.chance or 1
end

AdditionalShards:onAction(actions.Pickup, function(self, level, actor, action)
   local pickedup = action:getTarget(1)

   if pickedup:is(actors.Shard) and not action.extra and love.math.random() < self.chance then
      local extra = actor:getAction(actions.Pickup)(actor, actors.Shard())
      extra.extra = true
      level:performAction(extra, true)
   end
=======
	Condition.__new(self)
	self.chance = options.chance or 1
end

AdditionalShards:onAction(actions.Pickup, function(self, level, actor, action)
	local pickedup = action:getTarget(1)

	if pickedup:is(actors.Shard) and not action.extra and love.math.random() < self.chance then
		local extra = actor:getAction(actions.Pickup)(actor, actors.Shard())
		extra.extra = true
		level:performAction(extra, true)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end)

return AdditionalShards
