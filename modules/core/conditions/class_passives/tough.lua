local Condition = require "core.condition"

local Tough = Condition:extend()
Tough.name = "Tough"
Tough.description = "You gain 2 additional max HP when you gaze upon a prism."

function Tough:getMaxHP()
	local progression_component = self.owner:getComponent(components.Progression)
	return progression_component.level * 2
end

function Tough:onDescend(level, actor)
	local fighter_component = actor:getComponent(components.Fighter)
	fighter_component.charges = fighter_component.maxCharges
end

Tough:afterAction(
	actions.Choose_class,
	function(self, level, actor, action) actor.HP = actor.HP + 2 end
)

Tough:afterAction(actions.Level, function(self, level, actor, action) actor.HP = actor.HP + 2 end)

return Tough
