local Actor = require "core.actor"
local Action = require "core.action"
local Condition = require "core.condition"
local Tiles = require "display.tiles"
local LightColor = require "structures.lighting.lightcolor"

local ZapTarget = targets.Creature:extend()
ZapTarget.name = "ZapTarget"
ZapTarget.range = 6

local ZapWeapon = {
   stat = "MGK",
   name = "Wand of Chain Lightning",
   dice = "1d4",
   bonus = 2,
}

local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.aoeRange = 3
Zap.targets = { targets.Item, ZapTarget }

local lightningLight = Actor:extend()
lightningLight.name = "Chain Lightning"
lightningLight.color = { 1, 1, 0 }
lightningLight.visible = false
lightningLight.components = {
   components.Light {
      color = LightColor(31, 31, 0),
      falloff = 0.6,
      effect = { components.Light.effects.colorSwap, { LightColor(6, 17, 26), 2.0, 0.1 } },
   },
}

function Zap:perform(level)
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
   local targetsHit = 0
   light = lightningLight()

   
   level:addActor(light)
   level:moveActor(light, target.position)
   level:yield("wait", 0.6)
   if MakeSave(target) < (10 + self.owner:getStatBonus "MGK") then
      local damageAction = target:getReaction(reactions.Damage)(target, self.owner, damage)
      level:performAction(damageAction)
      targetsHit = targetsHit + 1
   else
      local damageAction = target:getReaction(reactions.Damage)(target, self.owner, math.floor(damage/2))
      level:performAction(damageAction)
   end
   level:removeActor(light)
   while targetsHit < 3 and #actors > 0 and additionalTarget ~= target do
      target = additionalTarget
      if additionalTarget:hasComponent(components.Stats) then
         trackedActors[additionalTarget] = true
         level:addActor(light)
         level:moveActor(light, target.position)
         level:yield("wait", 0.6)
         if MakeSave(target) < (10 + self.owner:getStatBonus "MGK") then
            local damageAction = target:getReaction(reactions.Damage)(target, self.owner, damage)
            level:performAction(damageAction)
            targetsHit = targetsHit + 1
         else
            local damageAction = target:getReaction(reactions.Damage)(target, self.owner, math.floor(damage/2))
            level:performAction(damageAction)
         end
         level:removeActor(light)
      end
   end
end

local WandOfChainLightning = Actor:extend()
WandOfChainLightning.name = "Wand of Lightning"
WandOfChainLightning.description = "Chaining damage all over the room? Keep me out of there."
WandOfChainLightning.color = { 1.0, 1.0, 0.0, 1 }
WandOfChainLightning.char = Tiles["wand_pointy"]

WandOfChainLightning.components = {
   components.Item { stackable = false },
   components.Usable(),
   components.Wand {
      maxCharges = 6,
      zap = Zap,
   },
   components.Cost { rarity = "common" },
}

return WandOfChainLightning
