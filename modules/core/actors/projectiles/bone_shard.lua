local Actor = require "core.actor"
local Tiles = require "display.tiles"
local Vector2 = require "math.vector"

local Bone_Shard = Actor:extend()
Bone_Shard.char = Tiles["bones_2"]
Bone_Shard.name = "Bone Shard"
Bone_Shard.color = { 0.89, 0.855, 0.788, 1}

Bone_Shard.components = {
    components.Projectile{
        range = 5,
        bounce = 0,
        damage = "1d2",
        effects = {}
    }
}

return Bone_Shard
