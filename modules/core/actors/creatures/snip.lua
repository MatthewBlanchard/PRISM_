local Actor = require "core.actor"
local Vector2 = require "math.vector"
local Tiles = require "display.tiles"
local Condition = require "core.condition"

local SingOnEat = Condition:extend()
SingOnEat.name = "Sing on Eat"

SingOnEat:onAction(actions.Eat, function(self, level, actor, action)
   local effects_system = level:getSystem "Effects"
   if effects_system then
      effects_system:addEffect(
         level,
         effects.CharacterDynamic(action.owner, 0, -1, Tiles["bubble_music"], { 1, 1, 1 }, 0.5)
      )
   end
end):where(Condition.ownerIsTarget)

local Snip = Actor:extend()

Snip.char = Tiles["snip_1"]
Snip.name = "snip"
Snip.description = "The sweet and savory song of the snip is a feast for the ears and the belly!"
Snip.color = { 0.97, 0.93, 0.55, 1 }

Snip.components = {
   components.Sight { range = 6, fov = true, explored = false },
   components.Move { speed = 200 },
   components.Stats {
      ATK = 0,
      MGK = 0,
      PR = 0,
      MR = 0,
      maxHP = 1,
      AC = 0,
   },
   components.Item { stackable = true },
   components.Usable(),
   components.Edible { nutrition = 2 },
   components.Aicontroller(),
   components.Animated {
      sheet = { Tiles["snip_1"], Tiles["snip_2"] },
   },
   components.Faction { "critter" },
}

function Snip:initialize() self:applyCondition(SingOnEat) end

local actUtil = components.Aicontroller
function Snip:act(level)
   local snip = actUtil.closestSeenActorByType(self, actors.Snip)
   local player = actUtil.closestSeenActorByType(self, actors.Player)
   local target = player or snip

   local effects_system = level:getSystem "Effects"
   if target then
      if self:getRange("box", target) < 3 and target == player and effects_system then
         effects_system:addEffectAfterAction(
            effects.CharacterDynamic(self, 0, -1, Tiles["bubble_music"], { 1, 1, 1 }, 0.5)
         )
      end
      return actUtil.crowdAround(self, target, true)
   end

   return actUtil.randomMove(level, self)
end

return Snip
