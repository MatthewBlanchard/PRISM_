local System = require "system"

local WeaponSystem = System:extend()
WeaponSystem.name = "Weapon"

function WeaponSystem:registerLights(level)
    local lights = {}

    for actor, attacker_component in level:eachActor(components.Attacker) do
        local wielded = attacker_component.wielded
        if wielded and wielded.is then
            local light_component = wielded:getComponent(components.Light)
            if light_component then
                table.insert(lights, {actor.position.x, actor.position.y, light_component})
            end
        end
    end

    return lights
end

return WeaponSystem