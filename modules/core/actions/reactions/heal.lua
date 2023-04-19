local Reaction = require "core.reaction"

local Heal = Reaction:extend()
Heal.name = "heal"
Heal.silent = true

function Heal:__new(owner, targets, heal, source, type)
	Reaction.__new(self, owner, targets)
	self.heal = heal
	self.source = source
end

function Heal:perform(level)
	self.owner.HP = math.min(self.owner.HP + self.heal, self.owner:getMaxHP())
	local effects_system = level:getSystem "Effects"
	if effects_system then
		effects_system:addEffect(level, effects.HealEffect(self.owner, self.heal))
	end
end

return Heal
