local Condition = require("core.condition")

local RefundCharge = Condition:extend()
RefundCharge.name = "refundcharge"

function RefundCharge:__new(options)
<<<<<<< HEAD
   Condition.__new(self)
   self.chance = options.chance or 1
end

RefundCharge:afterAction(actions.Zap, function(self, level, actor, action)
   local wand = action:getTarget(1)

   if love.math.random() > self.chance then wand:modifyCharges(1) end
=======
	Condition.__new(self)
	self.chance = options.chance or 1
end

RefundCharge:afterAction(actions.Zap, function(self, level, actor, action)
	local wand = action:getTarget(1)

	if love.math.random() > self.chance then
		wand:modifyCharges(1)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end)

return RefundCharge
