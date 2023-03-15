local System = require "system"

local Hunger = System:extend()
Hunger.name = "Message"

function Hunger:onTick(level, actor, action)
    for _, hunger_component in level:eachActor(components.Hunger) do
        hunger_component.satiation = hunger_component.satiation - 1
    end
end

return Hunger