local Actor = require("core.actor")
local Action = require("core.action")
local Condition = require("core.condition")
local Tiles = require("display.tiles")

local ZapTarget = targets.Actor:extend()
ZapTarget.name = "MindControlTarget"
ZapTarget.requirements = { components.Aicontroller }
ZapTarget.range = 6

function ZapTarget:validate(owner, actor)
<<<<<<< HEAD
   return targets.Actor.validate(self, owner, actor) and actor:hasComponent(components.Aicontroller)
=======
	return targets.Actor.validate(self, owner, actor) and actor:hasComponent(components.Aicontroller)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.targets = { targets.Item, ZapTarget }

function Zap:perform(level)
<<<<<<< HEAD
   actions.Zap.perform(self, level)
   local target = self.targetActors[2]
   target:applyCondition(conditions.Mind_control())
=======
	actions.Zap.perform(self, level)
	local target = self.targetActors[2]
	target:applyCondition(conditions.Mind_control())
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local WandOfMindControl = Actor:extend()
WandOfMindControl.name = "Wand of Mind Control"
WandOfMindControl.color = { 0.7, 0.1, 0.7, 1 }
WandOfMindControl.char = Tiles["wand_pointy"]

WandOfMindControl.components = {
<<<<<<< HEAD
   components.Item { stackable = false },
   components.Usable(),
   components.Wand {
      maxCharges = 5,
      zap = Zap,
   },
   components.Cost { rarity = "mythic" },
=======
	components.Item({ stackable = false }),
	components.Usable(),
	components.Wand({
		maxCharges = 5,
		zap = Zap,
	}),
	components.Cost({ rarity = "mythic" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return WandOfMindControl
