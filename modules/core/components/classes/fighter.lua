local Component = require("core.component")
local Condition = require("core.condition")
local Action = require("core.action")

local SecondWindCondition = Condition:extend()
SecondWindCondition.name = "Second Wind"
SecondWindCondition.description = "You center yourself and gain health back over time."

SecondWindCondition:onTick(function(self, level, actor)
	local heal = self.owner:getReaction(reactions.Heal)
	level:performAction(heal(actor, {}, 2))
end)

local SecondWindTarget = targets.Actor:extend()

function SecondWindTarget:validate(owner, actor)
	return owner == actor
end

-- Action that applies the Second Wind condition to the actor.
local SecondWind = Action:extend()
SecondWind.name = "activated Second Wind"

function SecondWind:__new(owner, targets)
	Action.__new(self, owner, targets)
end

function SecondWind:perform(level)
	local customSecondWind = SecondWindCondition:extend()
	customSecondWind:setDuration(500)
	local fighter = self.owner
	local fighter_component = fighter:getComponent(components.Fighter)

	if fighter_component.charges < 1 then
		self.time = 0
		return
	end

	fighter_component:modifyCharges(-1)

	self.owner:applyCondition(customSecondWind)
end

-- This component provides the active ability of the Fighter class to the actor
-- it is attached to.
local Fighter = Component:extend()
Fighter.name = "Fighter"
Fighter.description = "A chunky fighter with an active heal."

Fighter.actions = {
	SecondWind,
}

function Fighter:__new()
	self.charges = 1
	self.maxCharges = 1
end

function Fighter:modifyCharges(n)
	self.charges = math.min(math.max(self.charges + n, 0), self.maxCharges)
end

function Fighter:initialize(actor)
	local progression_component = actor:getComponent(components.Progression)
	progression_component.classAbility = SecondWind

	actor.ATK = actor.ATK + 1
	actor:applyCondition(conditions.Tough())
end

return Fighter
