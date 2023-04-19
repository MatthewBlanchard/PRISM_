local Actor = require("core.actor")
local Action = require("core.action")
local Condition = require("core.condition")
local Tiles = require("display.tiles")

local ZapTarget = targets.Actor:extend()
ZapTarget.name = "ZapTarget"
ZapTarget.requirements = { components.Stats }
ZapTarget.range = 6

local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.targets = { targets.Item, ZapTarget }

function Zap:perform(level)
<<<<<<< HEAD
   actions.Zap.perform(self, level)
   local target = self.targetActors[2]
   target:applyCondition(conditions.Lethargy())
=======
	actions.Zap.perform(self, level)
	local target = self.targetActors[2]
	target:applyCondition(conditions.Lethargy())
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local WandOfLethargy = Actor:extend()
WandOfLethargy.name = "Wand of Lethargy"
WandOfLethargy.color = { 0.7, 0.1, 0.7, 1 }
WandOfLethargy.char = Tiles["wand_pointy"]

WandOfLethargy.components = {
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

return WandOfLethargy
