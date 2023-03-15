local Condition = require "condition"

local Arcane = Condition:extend()
Arcane.name = "Arcane"
Arcane.description = "Each of your wands has a 50% chance to gain a charge upon descent."

function Arcane:onDescend(level, actor)
    local inventory_component = actor:getComponent(components.Inventory)
    
    for _, item in ipairs(inventory_component:getItems()) do
        if item:is(actors.Wand) then
            if love.math.random() > 0 then
                item:modifyCharges(1)
            end
        end
    end
end

return Arcane
