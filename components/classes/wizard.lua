local Component = require "component"
local Condition = require "condition"
local Action = require "action"

--activated ability
local Blast = actions.Zap:extend()
Blast.name = "blast"
Blast.targets = {targets.Item, BlastTarget}

function Blast:perform(level)
    local wizard = self.targetActors[1]
    local wizard_component = wizard:getComponent(components.Wizard)

    if wizard_component.charges <1 then
        return
    end

    wizard_component:modifyCharges(-1)

    if self:getTarget(2) then
        local effectPos = self:getTarget(2).position or self:getTarget(2)
        level:getSystem("Effects"):addEffect(effects.Zap(wand, self.owner, effectPos))
    end
    local target = self.targetActors[2]
    local attack = actions.Attack(self.owner, target, BlastWeapon)
    level:performAction(attack, true)
end

--class establishment
local Wizard = Component:extern()
Wizard.name = "Wizard"

Wizard.actions = {
    Blast
}

function Wizard:_new()
    self.charges = 3
    self.maxCharges = 3
end

function Wizard.modifyCharges()
    self.charges = math.min(math.max(self.charges + n, 0), self.maxCharges)
end

function Wizard:initialize(actor)
    actor:applyCondition(conditions.Arcane())
end

return Wizard