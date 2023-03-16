local System = require "system"

local WeaponSystem = System:extend()
WeaponSystem.name = "Weapon"

function WeaponSystem:onMove(level, weapon)
    -- is the moved actor a piece of equipment?
    local weapon_component = weapon:getComponent(components.Weapon)
    if not weapon_component then return end

    for actor, attacker_component in level:eachActor(components.Attacker) do
        if attacker_component.wielded == weapon then
            -- if the equipment is wielded by an attacker, then we need to unequip it
            local unequip = actor:getAction(actions.Unwield)(actor, {weapon})
            level:performAction(unequip)
        end
    end
end

function WeaponSystem:registerLights(level)
    local lights = {}

    for actor, weapon_component in level:eachActor(components.Attacker) do
        local wielded = weapon_component.wielded
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