local Action = require("core.action")

local AttackTarget = targets.Creature:extend()

local Attack = Action:extend()
Attack.name = "attack"
Attack.targets = { AttackTarget }

function Attack:__new(owner, defender, weapon)
<<<<<<< HEAD
   Action.__new(self, owner, { defender })
   self.weapon = weapon or owner:getComponent(components.Attacker).wielded
   self.time = self.weapon.time or 100
   self.damageBonus = 0
   self.diceBonuses = {}
   self.attackBonus = 0
   self.criticalOn = 20
end

function Attack:perform(level)
   local effects_system = level:getSystem "Effects"
   local weapon = self.weapon
   local weaponBonus = weapon.bonus or 0
   local bonus = self.owner:getStatBonus(weapon.stat) + weaponBonus + self.attackBonus
   local naturalRoll = self.owner:rollCheck(weapon.stat)
   local roll = naturalRoll + bonus

   local defender = self:getTarget(1)
   local dmg = ROT.Dice.roll(weapon.dice) + self.owner:getStatBonus(weapon.stat) + self.damageBonus

   for _, dice in ipairs(self.diceBonuses) do
      dmg = dmg + ROT.Dice.roll(dice)
   end

   local critical = naturalRoll >= self.criticalOn

   if roll >= defender:getAC() or critical then
      self.hit = true
      if critical then
         self.crit = true
         dmg = dmg * 2
         effects_system:addEffect(level, effects.CritEffect(defender))
      end

      local damage = defender:getReaction(reactions.Damage)(defender, { self.owner }, dmg)

      level:performAction(damage)
      return
   end

   if effects_system then
      effects_system:addEffect(
         level,
         effects.DamageEffect(self.owner.position, defender, dmg, false)
      )
   end
end

function Attack:addDiceBonus(dice) table.push(self.diceBonuses, dice) end
=======
	Action.__new(self, owner, { defender })
	self.weapon = weapon or owner:getComponent(components.Attacker).wielded
	self.time = self.weapon.time or 100
	self.damageBonus = 0
	self.diceBonuses = {}
	self.attackBonus = 0
	self.criticalOn = 20
end

function Attack:perform(level)
	local effects_system = level:getSystem("Effects")
	local weapon = self.weapon
	local weaponBonus = weapon.bonus or 0
	local bonus = self.owner:getStatBonus(weapon.stat) + weaponBonus + self.attackBonus
	local naturalRoll = self.owner:rollCheck(weapon.stat)
	local roll = naturalRoll + bonus

	local defender = self:getTarget(1)
	local dmg = ROT.Dice.roll(weapon.dice) + self.owner:getStatBonus(weapon.stat) + self.damageBonus

	for _, dice in ipairs(self.diceBonuses) do
		dmg = dmg + ROT.Dice.roll(dice)
	end

	local critical = naturalRoll >= self.criticalOn

	if roll >= defender:getAC() or critical then
		self.hit = true
		if critical then
			self.crit = true
			dmg = dmg * 2
			effects_system:addEffect(level, effects.CritEffect(defender))
		end

		local damage = defender:getReaction(reactions.Damage)(defender, { self.owner }, dmg)

		level:performAction(damage)
		return
	end

	if effects_system then
		effects_system:addEffect(level, effects.DamageEffect(self.owner.position, defender, dmg, false))
	end
end

function Attack:addDiceBonus(dice)
	table.push(self.diceBonuses, dice)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Attack
