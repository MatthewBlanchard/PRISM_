local Actor = require "core.actor"
local Vector2 = require "math.vector"
local Tiles = require "display.tiles"

local Wasp = Actor:extend()

Wasp.char = Tiles["sqeeto"]
Wasp.name = "stingboy"
Wasp.color = {0.30, 0.71, 0.37}

local poisonOnHit = conditions.Onhit:extend()

function poisonOnHit:onHit(level, attacker, defender)
    defender:applyCondition(conditions.Poisoned)
end

Wasp.components = {
  components.Collideable_box(),
  components.Sight{ range = 4, fov = true, explored = false },
  components.Move{ speed = 100 },
  components.Stats{
    ATK = 2,
    MGK = 0,
    PR = 0,
    MR = 0,
    maxHP = 5,
    AC = 5
  },

  components.Attacker{
    defaultAttack =
    {
      name = "Probiscus",
      stat = "ATK",
      dice = "1d1",
    }
  },

  components.Aicontroller(),
  components.Animated(),
  components.Faction{ "sqeeter" }
}

function Wasp:initialize()
    self:applyCondition(poisonOnHit())
end

local actUtil = components.Aicontroller
function Wasp:act(level)
  local highest = 0
  local highestLocation = nil
  local highestComponent = nil
  local wowFactor = false

  local effect_system = level:getSystem("Effects")
  local function playAnim(animateBool, actor)
    if not animateBool then return end
    effect_system:addEffectAfterAction(effects.CharacterDynamic(actor, 0, -1, Tiles["bubble_surprise"], {1, 1, 1}, .5))
  end
  
  -- all this needs to change, wasps attack everything, no fucks given
  -- flee from spiders
  local spider = actUtil.closestSeenActorByFaction(self, "arachnid")
  if spider then
    if effect_system then
      effect_system:addEffect(effects.CharacterDynamic(self, 0, -1, Tiles["bubble_lines"], {1, 1, 1}, .5))
    end
    return actUtil.moveAway(self, spider)
  end

  -- if a creature with the warmblooded faction tag is nearby attack it
  local warmblooded = actUtil.closestSeenActorByFaction(self, "warmblooded")
  if warmblooded and self:getRange("box", warmblooded) == 1  then
    return self:getAction(actions.Attack)(self, warmblooded)
  end
  
  -- find the brightest light source
  local lighting_system = level:getSystem("Lighting")
  local lights = lighting_system:getLights()
  local sight_component = self:getComponent(components.Sight)
  for x, _ in pairs(sight_component.fov) do
    for y, _ in pairs(sight_component.fov[x]) do
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
  end

  if highestLocation then
    if not (highestComponent == self.actTarget) then
      wowFactor = true
    end
    self.actTarget = highestComponent
  else
    self.actTarget = nil
  end

  if self.actTarget then
    playAnim(wowFactor, self)
    if math.random() > .75 then
      return actUtil.randomMove(level, self)
    end

    return actUtil.moveTowardVecAvoid(self, highestLocation)
  end

  return actUtil.moveTowardLight(level, self)
end

return Wasp
