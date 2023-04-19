local Actor = require("core.actor")
local Action = require("core.action")
local Condition = require("core.condition")
local Tiles = require("display.tiles")

local function PoofEffect(pos1, pos2)
<<<<<<< HEAD
   local t = 0
   return function(dt, interface)
      t = t + dt

      local color = { 0.4, 0.4, 0.4, 1 }
      interface:writeOffset(Tiles["poof"], pos1.x, pos1.y, color)
      interface:writeOffset(Tiles["poof"], pos2.x, pos2.y, color)
      if t > 0.3 then return true end
   end
=======
	local t = 0
	return function(dt, interface)
		t = t + dt

		local color = { 0.4, 0.4, 0.4, 1 }
		interface:writeOffset(Tiles["poof"], pos1.x, pos1.y, color)
		interface:writeOffset(Tiles["poof"], pos2.x, pos2.y, color)
		if t > 0.3 then
			return true
		end
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local ZapTarget = targets.Actor:extend()
ZapTarget.name = "ZapTarget"
ZapTarget.requirements = { components.Stats }
ZapTarget.range = 9

local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.targets = { targets.Item, ZapTarget }

function Zap:perform(level)
<<<<<<< HEAD
   actions.Zap.perform(self, level)

   local target = self.targetActors[2]
   local position = self.owner.position

   self.owner.position, target.position = target.position, self.owner.position
   level:addEffect(level, PoofEffect(self.owner.position, target.position))
=======
	actions.Zap.perform(self, level)

	local target = self.targetActors[2]
	local position = self.owner.position

	self.owner.position, target.position = target.position, self.owner.position
	level:addEffect(level, PoofEffect(self.owner.position, target.position))
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local WandOfSwapping = Actor:extend()
WandOfSwapping.name = "Wand of Swapping"
WandOfSwapping.color = { 0.1, 0.1, 1, 1 }
WandOfSwapping.char = Tiles["wand"]

WandOfSwapping.components = {
<<<<<<< HEAD
   components.Item { stackable = false },
   components.Usable(),
   components.Wand {
      maxCharges = 5,
      zap = Zap,
   },
   components.Cost { rarity = "common" },
=======
	components.Item({ stackable = false }),
	components.Usable(),
	components.Wand({
		maxCharges = 5,
		zap = Zap,
	}),
	components.Cost({ rarity = "common" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return WandOfSwapping
