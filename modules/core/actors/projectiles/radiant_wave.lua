local Actor = require("core.actor")
local Tiles = require("display.tiles")
local Vector2 = require("math.vector")
local LightColor = require("structures.lighting.lightcolor")

local Bone_Shard = Actor:extend()
Bone_Shard.char = Tiles["pointy_poof"]
Bone_Shard.name = "Radiant Wave"
Bone_Shard.color = { 0.89, 0.855, 0.788, 1 }

Bone_Shard.components = {
	components.Light({
		color = LightColor(4, 10, 22),
	}),
	components.Projectile({
		range = 5,
		bounce = 1,
		damage = "1d4",
		effects = {},
	}),
}

return Bone_Shard
