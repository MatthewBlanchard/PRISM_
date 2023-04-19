local Actor = require("core.actor")
local Vector2 = require("math.vector")
local Tiles = require("display.tiles")

local Webweaver = Actor:extend()

Webweaver.char = Tiles["spider_1"]
Webweaver.name = "weaver"
Webweaver.color = { 0.7, 0.7, 0.9 }

Webweaver.actions = {
	actions.Web,
}

Webweaver.components = {
	components.Collideable_box(),
	components.Sight({ range = 8, fov = true, explored = false }),
	components.Move({ speed = 75 }),
	components.Stats({
		ATK = 1,
		MGK = 0,
		PR = 0,
		MR = 0,
		maxHP = 8,
		AC = 2,
	}),

	components.Attacker({
		defaultAttack = {
			name = "Fangs",
			stat = "ATK",
			dice = "1d2",
		},
	}),

	components.Aicontroller(),
	components.Animated({
		sheet = { Tiles["spider_1"], Tiles["spider_2"] },
	}),
	components.Faction({ "arachnid" }),
}

local actUtil = components.Aicontroller
function Webweaver:act(level)
	local target
	local prey = actUtil.closestSeenActorByFaction(self, "sqeeter") or actUtil.closestSeenActorByFaction(self, "fink")
	local threat = actUtil.closestSeenActorByType(self, actors.Player)

	if prey then
		target = prey
	elseif threat then
		target = threat
	end

	local effects_system = level:getSystem("Effects")
	if target and self._lastTarget ~= target and effects_system then
		local targetFaction = target:getComponent(components.Faction)
		if targetFaction:has({ "sqeeter" }) then
			effects_system:addEffectAfterAction(
				effects.CharacterDynamic(self, 0, -1, Tiles["bubble_food"], { 1, 1, 1 }, 0.5)
			)
		elseif target:is(actors.Player) then
			effects_system:addEffectAfterAction(
				effects.CharacterDynamic(self, 0, -1, Tiles["bubble_angry"], { 1, 1, 1 }, 0.5)
			)
		end
	end

	self._lastTarget = target

	if target then
		assert(target:is(Actor))

		local targetRange = target:getRange("box", self)
		if targetRange == 1 then
			return self:getAction(actions.Attack)(self, target)
		elseif target:hasCondition(conditions.Slowed) then
			return actUtil.moveToward(self, target)
		elseif targetRange >= 2 and targetRange <= 4 then
			return self:getAction(actions.Web)(self, { target })
		elseif target:getRange("box", self) <= 2 then
			return actUtil.moveAway(self, target)
		else
			return actUtil.moveToward(self, target)
		end
	else
		return actUtil.randomMove(level, self)
	end
end

return Webweaver
