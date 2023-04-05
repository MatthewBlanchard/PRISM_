local Action = require "core.action"
local Bresenham = require "math.bresenham"
local Vector2 = require "math.vector"

local Tongue = Action:extend()
Tongue.name = "Tongue"
Tongue.targets = {targets.Creature}

function Tongue:perform(level)
    local target = self:getTarget(1)
    local line, valid = Bresenham.line(self.owner.position.x, self.owner.position.y, target.position.x, target.position.y)
    local goalpos = Vector2(line[2][1], line[2][2])
    for i, point in ipairs (line) do
        local additionaltarget = level:getActorsAt(point[1], point[2])
        for _, actor in ipairs (additionaltarget) do
            local actor_collide = actor:hasComponent(components.Collideable)
            if not actor_collide then
                local damageAmount = ROT.Dice.roll("1d1")
                local damageAction = target:getReaction(reactions.Damage)(target, {self.owner}, damageAmount)
                level:performAction(damageAction)
                --level:addEffect(level, effects.LineEffect(goalpos, Vector2(point[1], point[2])))
                level:moveActor(target, goalpos)
                return
            end
        end
    end
end

return Tongue