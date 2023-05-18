local Action = require "core.action"

local TripTarget = targets.Creature:extend()

local Trip = Action:extend()
Trip.name = "trip"
Trip.targets = { TripTarget }

function Trip: _new(owner, defender)
    Action.__new(self.owner, { defender })
    self.time = 100
end

function Trip:perform(level)
    local roll = self.owner:rollCheck("ATK")

    local defender = self:getTarget(1)

    if roll >= defender:getAC() then
        self.hit = true
        local trip = defender:applyCondition(condtiions.Prone)
        return
    end
end