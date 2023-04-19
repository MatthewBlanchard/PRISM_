local Actor = require "core.actor"
local Vector2 = require "math.vector"
local Tiles = require "display.tiles"
local Condition = require "core.condition"

local Explode = Condition:extend()
Explode.range = 1
Explode.damage = "1d4"
Explode.color = { 90 / 230, 161 / 230, 74 / 230 }

Explode:afterAction(actions.Throw, function(self, level, actor, action)
	local fov, actors = level:getAOE("fov", actor.position, Explode.range)
	local damage = ROT.Dice.roll(self.damage) + 1

	local effects_system = level:getSystem "Effects"
	effects_system:addEffect(
		level,
		effects.ExplosionEffect(fov, actor.position, Explode.range, Explode.color)
	)

	local lighting_system = level:getSystem "Lighting"
	if lighting_system then
		lighting_system:addTemporaryLight(
			effects.LightEffect(actor.position.x, actor.position.y, 0.6, Explode.color, 2)
		)
	end

	effects_system:suppressEffects()
	for _, a in ipairs(actors) do
		if targets.Creature:validate(self.owner, a) then
			local damage = a:getReaction(reactions.Damage)(a, { action.owner }, damage, actor)
			level:performAction(damage)
		end
	end
	effects_system:resumeEffects(level)

	level:removeActor(actor)
end):where(Condition.ownerIsTarget)

local Gloop = Actor:extend()

Gloop.char = Tiles["gloop_1"]
Gloop.name = "gloop"
Gloop.color = { 90 / 230, 161 / 230, 74 / 230 }

Gloop.components = {
	components.Sight { range = 6, fov = true, explored = false },
	components.Move { speed = 100 },
	components.Stats {
		ATK = 0,
		MGK = 0,
		PR = 0,
		MR = 0,
		maxHP = 1,
		AC = 0,
	},
	components.Item { stackable = true },
	components.Aicontroller(),
	components.Animated {
		sheet = { Tiles["gloop_1"], Tiles["gloop_2"] },
	},
	components.Faction { "critter" },
}

function Gloop:initialize() self:applyCondition(Explode()) end

local actUtil = components.Aicontroller
function Gloop:act(level)
	local effects_system = level:getSystem "Effects"
	local seen_player = actUtil.closestSeenActorByType(self, actors.Player)
	if seen_player and effects_system then
		effects_system:addEffectAfterAction(
			effects.CharacterDynamic(self, 0, -1, Tiles["bubble_lines"], { 1, 1, 1 }, 0.5)
		)
		self._meanderDirection = nil
		return actUtil.moveAway(self, seen_player)
	end

	if
		not self._meanderDirection
		or not actUtil.isPassable(self, self.position + self._meanderDirection)
	then
		self._meanderDirection = actUtil.getPassableDirection(self)
	end

	return actUtil.move(self, self._meanderDirection)
end

return Gloop
