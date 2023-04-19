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
   name = "Wand of Lightning",
   dice = "1d4",
   bonus = 2,
=======
	stat = "MGK",
	name = "Wand of Lightning",
	dice = "1d4",
	bonus = 2,
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.aoeRange = 3
Zap.targets = { targets.Item, ZapTarget }

function Zap:perform(level)
<<<<<<< HEAD
   actions.Zap.perform(self, level)
   local target = self.targetActors[2]
   local fov, actors = level:getAOE("fov", target.position, self.aoeRange)
   local trackedActors = {}
   trackedActors[target] = true

   local function MakeSave(target)
      local save = target:rollCheck "MR"
      if target == self.owner then save = target:rollCheck("MR" + 2) end
      return save
   end

   local damage = ROT.Dice.roll "2d4"
   local additionalTarget = table.remove(actors, 1)
   local targetsHit = 1

   if MakeSave(target) < (10 + self.owner:getStatBonus "MGK") then
      local damageAction = target:getReaction(reactions.Damage)(target, self.owner, damage)
      level:performAction(damageAction)
      while targetsHit < 3 and #actors > 0 and additionalTarget ~= target do
         target = additionalTarget
         if MakeSave(target) < (10 + self.owner:getStatBonus "MGK") then
            damageAction = target:getReaction(reactions.Damage)(target, self.owner, damage)
            level:performAction(damageAction)
            targetsHit = targetsHit + 1
         else
            return
         end
      end
   end
=======
	actions.Zap.perform(self, level)
	local target = self.targetActors[2]
	local fov, actors = level:getAOE("fov", target.position, self.aoeRange)
	local trackedActors = {}
	trackedActors[target] = true

	local function MakeSave(target)
		local save = target:rollCheck("MR")
		if target == self.owner then
			save = target:rollCheck("MR" + 2)
		end
		return save
	end

	local damage = ROT.Dice.roll("2d4")
	local additionalTarget = table.remove(actors, 1)
	local targetsHit = 1

	if MakeSave(target) < (10 + self.owner:getStatBonus("MGK")) then
		local damageAction = target:getReaction(reactions.Damage)(target, self.owner, damage)
		level:performAction(damageAction)
		while targetsHit < 3 and #actors > 0 and additionalTarget ~= target do
			target = additionalTarget
			if MakeSave(target) < (10 + self.owner:getStatBonus("MGK")) then
				damageAction = target:getReaction(reactions.Damage)(target, self.owner, damage)
				level:performAction(damageAction)
				targetsHit = targetsHit + 1
			else
				return
			end
		end
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local WandOfLightning = Actor:extend()
WandOfLightning.name = "Wand of Lightning"
WandOfLightning.description = "Chaining damage all over the room? Keep me out of there."
WandOfLightning.color = { 1.0, 1.0, 0.0, 1 }
WandOfLightning.char = Tiles["wand_pointy"]

WandOfLightning.components = {
<<<<<<< HEAD
   components.Item { stackable = false },
   components.Usable(),
   components.Wand {
      maxCharges = 6,
      zap = Zap,
   },
   components.Cost { rarity = "common" },
=======
	components.Item({ stackable = false }),
	components.Usable(),
	components.Wand({
		maxCharges = 6,
		zap = Zap,
	}),
	components.Cost({ rarity = "common" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return WandOfLightning
