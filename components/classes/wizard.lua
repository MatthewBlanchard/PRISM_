local Component = require "component"
local Condition = require "condition"
local Action = require "action"

local BlastTarget = targets.Creature:extend()
BlastTarget.name = "BlastTarget"
BlastTarget.range = 4


local BlastWeapon = {
  stat = "MGK",
  name = "magic blast",
  dice = "1d2",
  bonus = 1,
}

--activated ability
local Blast = actions.Zap:extend()
Blast.name = "blast"
Blast.targets = {BlastTarget}

function Blast:perform(level)
    local wizard = self.owner
    local wizard_component = wizard:getComponent(components.Wizard)

    if wizard_component.charges < 1  then
        return
    end

    wizard_component:modifyCharges(-1)

    local target = self:getTarget(1)
    level:getSystem("Effects"):addEffect(effects.Zap(self.owner, self.owner, target.position))

    actions.Attack(self.owner, target, BlastWeapon):perform(level)
end

--class establishment
local Wizard = Component:extend()
Wizard.name = "Wizard"
Wizard.description = "A wand slinging nerd who regains wand charges each floor."

Wizard.actions = {
    Blast
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
end

return Wizard