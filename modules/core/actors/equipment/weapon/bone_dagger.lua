local Actor = require "core.actor"
local Tiles = require "display.tiles"
local Vector2 = require "math.vector"

local directions = {
  [Vector2.UP] = {Vector2.UP_RIGHT, Vector2.UP_LEFT},
  [Vector2.RIGHT] = {Vector2.UP_RIGHT, Vector2.DOWN_RIGHT},
  [Vector2.DOWN] = {Vector2.DOWN_RIGHT, Vector2.DOWN_LEFT},
  [Vector2.LEFT] = {Vector2.UP_LEFT, Vector2.DOWN_LEFT},
  [Vector2.UP_RIGHT] = {Vector2.UP, Vector2.RIGHT},
  [Vector2.UP_LEFT] = {Vector2.LEFT, Vector2.UP},
  [Vector2.DOWN_RIGHT] = {Vector2.RIGHT, Vector2.DOWN},
  [Vector2.DOWN_LEFT] = {Vector2.DOWN, Vector2.LEFT}
}

local function getDirections(vec)
  for k, v in pairs(directions) do 
      if vec == k then 
      return v
      end
  end
end

local boneShardOnHit = conditions.Onhit:extend()

function boneShardOnHit:onHit(level, attacker, defender)
  local baseDirection = defender.position - attacker.position
  local directionsToHit = getDirections(baseDirection)
  local finalDirections = {}
  local shards = {}

  for k, v in ipairs(directionsToHit) do
    table.insert(finalDirections, v)
  end

  table.insert(finalDirections, baseDirection)

  for k, v in ipairs(finalDirections) do
    local shard = actors.Bone_shard()
    local projectileComponent = shard:getComponent(components.Projectile)
    projectileComponent.direction = v
    shard.position = defender.position

    level:addActor(shard)
    level:moveActor(shard, defender.position)
    table.insert(shards, shard)
  end

  local projectile_system = level:getSystem("Projectile")
  projectile_system:process(level)
end

local Bone_Dagger = Actor:extend()
Bone_Dagger.char = Tiles["shortsword"]
Bone_Dagger.name = "Rib Ripper"
Bone_Dagger.color = { 0.89, 0.855, 0.788, 1}

Bone_Dagger.components = {
  components.Item(),
  components.Weapon{
    stat = "ATK",
    name = "Rib Ripper",
    dice = "1d4",
    bonus = 1,
    time = 50,
    effects = {
      boneShardOnHit
    }
  },
  components.Cost{}
}

return Bone_Dagger
