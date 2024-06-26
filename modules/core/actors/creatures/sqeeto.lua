local Actor = require "core.actor"
local Vector2 = require "math.vector"
local Tiles = require "display.tiles"
local LightColor = require "structures.lighting.lightcolor"

local Sqeeto = Actor:extend()

Sqeeto.char = Tiles["sqeeto_1"]
Sqeeto.name = "sqeeter"
Sqeeto.color = { 0.8, 0.7, 0.09 }

Sqeeto.components = {
   components.Collideable_box(),
   components.Sight { range = 4, fov = true, explored = false, darkvision = 8 },
   components.Move { speed = 100 },
   components.Stats {
      ATK = 0,
      MGK = 0,
      PR = 0,
      MR = 0,
      maxHP = 3,
      AC = 2,
   },

   components.Attacker {
      defaultAttack = {
         name = "Probiscus",
         stat = "ATK",
         dice = "1d1",
      },
   },

   components.Aicontroller(),
   components.Animated {
      sheet = { Tiles["sqeeto_1"], Tiles["sqeeto_2"] },
   },
   components.Faction { "sqeeter" },
}

local actUtil = components.Aicontroller
function Sqeeto:act(level)
   local highest = 0
   local highestLocation = nil
   local highestComponent = nil
   local wowFactor = false

   local effect_system = level:getSystem "Effects"
   local function playAnim(animateBool, actor)
      if not animateBool then return end
      effect_system:addEffectAfterAction(
         effects.CharacterDynamic(actor, 0, -1, Tiles["bubble_surprise"], { 1, 1, 1 }, 0.5)
      )
   end

   -- flee from spiders
   local spider = actUtil.closestSeenActorByFaction(self, "arachnid")
   if spider then
      if effect_system then
         effect_system:addEffect(
            level,
            effects.CharacterDynamic(self, 0, -1, Tiles["bubble_lines"], { 1, 1, 1 }, 0.5)
         )
      end
      return actUtil.moveAway(self, spider)
   end

   -- if a creature with the warmblooded faction tag is nearby attack it
   local warmblooded = actUtil.closestSeenActorByFaction(self, "warmblooded")
   if warmblooded and self:getRange("box", warmblooded) == 1 then
      return self:getAction(actions.Attack)(self, warmblooded)
   end

   -- find the brightest light source
   local lighting_system = level:getSystem "Lighting"
   local lights = lighting_system:getLights()
   local sight_component = self:getComponent(components.Sight)
   for x, y in sight_component.fov:each() do
      local local_lights = lights:get(x, y)
      for light, _ in pairs(local_lights) do
         local value = light.color:average_brightness()

         if value > highest then
            highest = value
            highestLocation = Vector2(x, y)
            highestComponent = light
         end
      end
   end

   if highestLocation then
      if not (highestComponent == self.actTarget) then wowFactor = true end
      self.actTarget = highestComponent
   else
      self.actTarget = nil
   end

   if self.actTarget then
      playAnim(wowFactor, self)
      if math.random() > 0.75 then return actUtil.randomMove(level, self) end

      return actUtil.crowdAround(self, highestLocation, true)
   end

   return actUtil.moveTowardLight(level, self)
end

return Sqeeto
