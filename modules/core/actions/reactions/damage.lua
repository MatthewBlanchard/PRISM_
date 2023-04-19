local Reaction = require("core.reaction")

local Damage = Reaction:extend()
Damage.name = "damage"
Damage.silent = true

function Damage:__new(owner, dealer, damage)
<<<<<<< HEAD
   assert(dealer, "No dealer for damage reaction")
   assert(type(damage) == "number", "No damage for damage reaction")
   Reaction.__new(self, owner, nil)
   self.dealer = dealer
   self.damage = damage
end

function Damage:perform(level)
   -- TODO: Add actual damage types and change this to use them
   self.damage = math.max(0, self.damage - self.owner:getStat "PR")
   self.owner.HP = math.max(self.owner.HP - self.damage, 0)

   local effects_system = level:getSystem "Effects"
   if effects_system then
      effects_system:addEffect(
         level,
         effects.DamageEffect(self.dealer.position, self.owner, self.damage, self.damage > 0)
      )
   end
   if self.owner.HP == 0 then
      local die = self.owner:getReaction(reactions.Die)(self.owner, { self.dealer }, self.damage)
      level:performAction(die)
   end
=======
	assert(dealer, "No dealer for damage reaction")
	assert(type(damage) == "number", "No damage for damage reaction")
	Reaction.__new(self, owner, nil)
	self.dealer = dealer
	self.damage = damage
end

function Damage:perform(level)
	-- TODO: Add actual damage types and change this to use them
	self.damage = math.max(0, self.damage - self.owner:getStat("PR"))
	self.owner.HP = math.max(self.owner.HP - self.damage, 0)

	local effects_system = level:getSystem("Effects")
	if effects_system then
		effects_system:addEffect(
			level,
			effects.DamageEffect(self.dealer.position, self.owner, self.damage, self.damage > 0)
		)
	end
	if self.owner.HP == 0 then
		local die = self.owner:getReaction(reactions.Die)(self.owner, { self.dealer }, self.damage)
		level:performAction(die)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Damage
