local Actor = require "actor"
local Tiles = require "tiles"
local OnCrit = require "conditions.oncrit"

local WandSword = Actor:extend()
WandSword.char = Tiles["shortsword"]
WandSword.name = "Sword of Wand Recovery"
WandSword.color = { 0.627, 0.125, 0.941, 1}

local lightEffect = components.Light.effects.pulse({ 0.627, 0.125, 0.941, 1}, 0.5, 0.2)

--need to add an interface here to allow you to select a single wand to recharge
local WandRecovery = OnCrit:extend()
function WandRecovery:OnCrit(level, actor)
    local inventory_component = actor:getComponent(components.Inventory)
    for _, item in ipairs(inventory_component:getItems()) do
        if item:hasComponent(components.Wand) then
            item:modifyCharges(1)
        end
    end
end

WandSword.components = {
    components.Item(),
    components.Weapon{
        stat = "MGK",
        name = "WandSword",
        dice = "1d4",
        bonus = 1,
        time = 100,
        effects = {WandRecovery()}
    },
    components.Light{
        color = { 0.627, 0.125, 0.941, 1},
        intensity = 3,
        effect = lightEffect
    },
    components.Cost{rarity = "rare"}
}

return WandSword