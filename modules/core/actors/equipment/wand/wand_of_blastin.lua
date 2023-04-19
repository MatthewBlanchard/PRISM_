local Actor = require("core.actor")
local Action = require("core.action")
local Condition = require("core.condition")
local Tiles = require("display.tiles")

local ZapTarget = targets.Creature:extend()
ZapTarget.name = "ZapTarget"
ZapTarget.range = 6

local ZapWeapon = {
<<<<<<< HEAD
   stat = "MGK",
   name = "Wand of Blastin'",
   dice = "1d8",
=======
	stat = "MGK",
	name = "Wand of Blastin'",
	dice = "1d8",
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.targets = { targets.Item, ZapTarget }

function Zap:perform(level)
<<<<<<< HEAD
   actions.Zap.perform(self, level)
   local target = self.targetActors[2]
   local attack = actions.Attack(self.owner, target, ZapWeapon)
   level:performAction(attack, true)
=======
	actions.Zap.perform(self, level)
	local target = self.targetActors[2]
	local attack = actions.Attack(self.owner, target, ZapWeapon)
	level:performAction(attack, true)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local WandOfBlastin = Actor:extend()
WandOfBlastin.name = "Wand of Blastin'"
WandOfBlastin.description = "This thing packs a punch. Hope I'm not around when you start blastin'"
WandOfBlastin.color = { 0.8, 0.8, 0.8, 1 }
WandOfBlastin.char = Tiles["wand_pointy"]

WandOfBlastin.components = {
<<<<<<< HEAD
   components.Item { stackable = false },
   components.Usable(),
   components.Wand {
      maxCharges = 12,
      zap = Zap,
   },
   components.Cost { rarity = "common" },
=======
	components.Item({ stackable = false }),
	components.Usable(),
	components.Wand({
		maxCharges = 12,
		zap = Zap,
	}),
	components.Cost({ rarity = "common" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return WandOfBlastin
