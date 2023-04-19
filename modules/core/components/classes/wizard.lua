local Component = require("core.component")
local Condition = require("core.condition")
local Action = require("core.action")

local BlastTarget = targets.Creature:extend()
BlastTarget.name = "BlastTarget"
BlastTarget.range = 4

local BlastWeapon = {
<<<<<<< HEAD
   stat = "MGK",
   name = "magic blast",
   dice = "1d2",
   bonus = 1,
=======
	stat = "MGK",
	name = "magic blast",
	dice = "1d2",
	bonus = 1,
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

--activated ability
local Blast = actions.Zap:extend()
Blast.name = "blast"
Blast.targets = { BlastTarget }

function Blast:perform(level)
<<<<<<< HEAD
   local wizard = self.owner
   local wizard_component = wizard:getComponent(components.Wizard)

   if wizard_component.charges < 1 then return end

   wizard_component:modifyCharges(-1)

   local target = self:getTarget(1)
   level:getSystem("Effects"):addEffect(level, effects.Zap(self.owner, self.owner, target.position))

   actions.Attack(self.owner, target, BlastWeapon):perform(level)
=======
	local wizard = self.owner
	local wizard_component = wizard:getComponent(components.Wizard)

	if wizard_component.charges < 1 then
		return
	end

	wizard_component:modifyCharges(-1)

	local target = self:getTarget(1)
	level:getSystem("Effects"):addEffect(level, effects.Zap(self.owner, self.owner, target.position))

	actions.Attack(self.owner, target, BlastWeapon):perform(level)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

--class establishment
local Wizard = Component:extend()
Wizard.name = "Wizard"
Wizard.description = "A wand slinging nerd who regains wand charges each floor."

Wizard.actions = {
<<<<<<< HEAD
   Blast,
}

function Wizard:__new()
   self.charges = 7
   self.maxCharges = 7
end

function Wizard:modifyCharges(n)
   self.charges = math.min(math.max(self.charges + n, 0), self.maxCharges)
end

function Wizard:initialize(actor)
   local progression_component = actor:getComponent(components.Progression)
   progression_component.classAbility = Blast

   actor.MGK = actor.MGK + 1
   actor:applyCondition(conditions.Arcane())
=======
	Blast,
}

function Wizard:__new()
	self.charges = 7
	self.maxCharges = 7
end

function Wizard:modifyCharges(n)
	self.charges = math.min(math.max(self.charges + n, 0), self.maxCharges)
end

function Wizard:initialize(actor)
	local progression_component = actor:getComponent(components.Progression)
	progression_component.classAbility = Blast

	actor.MGK = actor.MGK + 1
	actor:applyCondition(conditions.Arcane())
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Wizard
