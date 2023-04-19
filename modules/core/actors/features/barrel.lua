local Actor = require("core.actor")
local Action = require("core.action")
local Tiles = require("display.tiles")
local Condition = require("core.condition")

local Explode = Condition:extend()
Explode.range = 2
Explode.color = { 0.8, 0.5, 0.1 }

Explode:afterReaction(reactions.Die, function(self, level, actor, action)
	local fov, actors = level:getAOE("fov", actor.position, Explode.range)
	local damageAmount = ROT.Dice.roll("6d6")

	for _, a in ipairs(actors) do
		if targets.Creature:checkRequirements(a) then
			local damage = a:getReaction(reactions.Damage)(a, { actor }, damageAmount)
			level:performAction(damage)
		end
	end

	level:addEffect(level, effects.ExplosionEffect(fov, actor.position, Explode.range))
	table.insert(level.temporaryLights, effects.LightEffect(actor.position.x, actor.position.y, 0.6, Explode.color))
end)

local Barrel = Actor:extend()

Barrel.char = Tiles["barrel"]
Barrel.name = "barrel"

Barrel.components = {
	components.Collideable_box(),
	components.Stats({
		maxHP = 1,
	}),
}

function Barrel:initialize()
	self:applyCondition(Explode())
end

return Barrel
