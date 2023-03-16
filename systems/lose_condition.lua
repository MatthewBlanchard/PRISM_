local System = require "system"

local LoseCondition = System:extend()
LoseCondition.name = "LoseCondition"

function LoseCondition:afterAction(level, actor, action)
    if action:is(reactions.Die) and actor:is(actors.Player) then
        level:quit()
    end
end

return LoseCondition