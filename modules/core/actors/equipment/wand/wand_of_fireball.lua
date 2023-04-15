local Actor = require "core.actor"
local Action = require "core.action"
local Condition = require "core.condition"
local Tiles = require "display.tiles"
local Color = require "math.color"
local LightColor = require "structures.lighting.lightcolor"
local Bresenham = require "math.bresenham"
local Vector2 = require "math.vector"

local fireballLight = Actor:extend()
fireballLight.name = "Fireball"
fireballLight.color = {1, 0.6, 0.2}
fireballLight.char = Tiles["projectile1"]
fireballLight.components = {
  components.Light{
    color = LightColor(28, 16, 1),
    effect = {components.Light.effects.flicker, {0.15, 0.3}},
  },
  components.Animated{
    sheet = { Tiles["projectile1"], Tiles["projectile2"] }
  }
}

local ZapTarget = targets.Point:extend()
ZapTarget.name = "ZapTarget"
ZapTarget.range = 9

local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.aoeRange = 2
Zap.targets = {targets.Item, ZapTarget}

function Zap:perform(level)
  actions.Zap.perform(self, level, true)

  local pointTarget = self.targetActors[2]

  local fov, actors = level:getAOE("fov", pointTarget, self.aoeRange)
  local damage = ROT.Dice.roll("2d6")

  local light = fireballLight()
  level:addActor(light)
  level:moveActor(light, pointTarget)

  local ox, oy = self.owner.position.x, self.owner.position.y
  local px, py = pointTarget.x, pointTarget.y
  local line, valid = Bresenham.line(ox, oy, px, py)

  for i = 2, #line do
    level:moveActor(light, Vector2(line[i][1], line[i][2]))
    level:yield("wait", 0.1)
  end

  local effects_system = level:getSystem("Effects")
  effects_system:addEffect(level, effects.ExplosionEffect(fov, pointTarget, self.aoeRange))

  level:removeActor(light)

  effects_system:suppressEffects()
  for i, actor in ipairs(actors) do
    if targets.Creature:validate(self.owner, actor) then
      local damage = actor:getReaction(reactions.Damage)(actor, {self.owner}, damage, self.targetActors[1])
      level:performAction(damage)
    end
  end
  effects_system:resumeEffects(level)
end

local WandOfFireball = Actor:extend()
WandOfFireball.name = "Wand of Fireball"
WandOfFireball.description = "Blasts a small area with a ball of fire."
WandOfFireball.color = {1, 0.6, 0.2, 1}
WandOfFireball.char = Tiles["wand_gnarly"]

WandOfFireball.components = {
  components.Item{stackable = false},
  components.Usable(),
  components.Wand{
    maxCharges = 5,
    zap = Zap
  },
  components.Cost{rarity = "rare"}
}

return WandOfFireball
