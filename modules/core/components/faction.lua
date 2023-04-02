local Component = require "core.component"

local Faction = Component:extend()
Faction.name = "Faction"

function Faction:__new(factions)
    -- create a hash set of the list of factions and store it in the component
    for k,v in pairs(factions) do
        self[v] = true
    end
end

function Faction:has(faction)
    return self[faction]
end

return Faction
