local Actor = require "core.actor"
local Action = require "core.action"
local Condition = require "core.condition"
local Tiles = require "display.tiles"

local Explode = Condition:extend()
Explode.range = 4
Explode.color = { 0.8 * 3, 0.8 * 3, 0.1 * 3 }

function Explode:onDurationEnd(level, actor)
   local lighting_system = level:getSystem "Lighting"
   local effects_system = level:getSystem "Effects"

   local fov, actors = level:getAOE("fov", actor.position, Explode.range)
   local damage = ROT.Dice.roll "6d6"

   level:removeActor(actor)
   table.insert(
      lighting_system.__temporaryLights,
      effects.LightEffect(actor.position.x, actor.position.y, 0.6, Explode.color)
   )
   effects_system:addEffect(level, effects.ExplosionEffect(fov, actor.position, Explode.range))

   effects_system:suppressEffects()
   for _, a in ipairs(actors) do
      if targets.Creature:validate(actor, a) then
         local damage = a:getReaction(reactions.Damage)(a, { actor }, damage, actor)
         level:performAction(damage)
      end
   end
   effects_system:resumeEffects(level)
end

local Arm = Action:extend()
Arm.name = "arm"
Arm.targets = { targets.Item }

function Arm:perform(level)
   local bomb = self:getTarget(1)
   local explode_condition = Explode()
   explode_condition:setDuration(500)

   bomb:applyCondition(explode_condition)
end

local Bomb = Actor:extend()

Bomb.name = "Bomb"
Bomb.char = Tiles["bomb"]
Bomb.color = { 0.4, 0.4, 0.4, 1 }
Bomb.description = "A bomb, I think you know what to do with it."

function Bomb:initialize() self:applyCondition(Explode()) end

Bomb.components = {
   components.Item { stackable = true },
   components.Cost {
      cost = 7,
      rarity = "uncommon",
   },
   components.Usable { Arm },
}

return Bomb
