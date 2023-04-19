local Actor = require "core.actor"
local Tiles = require "display.tiles"
local Vector2 = require "math.vector"

local waveOnHit = conditions.Onhit:extend()

function waveOnHit:onHit(level, attacker, defender)
	local projectile_system = level:getSystem "Projectile"
	local baseDirection = defender.position - attacker.position

	local wave = actors.Radiant_wave()
	local projectileComponent = wave:getComponent(components.Projectile)
	projectileComponent.direction = baseDirection
	wave.position = defender.position

	level:addActor(wave)
	projectile_system:process(level)
end

local Bone_Dagger = Actor:extend()
Bone_Dagger.char = Tiles["longsword"]
Bone_Dagger.name = "Radiant Waveblade"
Bone_Dagger.color = { 0.89, 0.855, 0.788, 1 }

Bone_Dagger.components = {
	components.Item(),
	components.Weapon {
		stat = "ATK",
		name = "Radiant Waveblade",
		dice = "1d8",
		bonus = 1,
		time = 100,
		effects = {
			waveOnHit,
		},
	},
	components.Cost {},
}

return Bone_Dagger
