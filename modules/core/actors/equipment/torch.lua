local Actor = require "core.actor"
local Tiles = require "display.tiles"
local LightColor = require "structures.lighting.lightcolor"

local burnOnHit = conditions.Onhit:extend()

function burnOnHit:onHit(level, attacker, defender) 
  local roll = ROT.Dice.roll("1d3")
  if roll == 1 then
    defender:applyCondition(conditions.Burning) 
  end
end

local Torch = Actor:extend()
Torch.char = Tiles["torch"]
Torch.name = "torch"
Torch.color = { 0.8666, 0.4509, 0.0862, 1 }

Torch.components = {
   components.Light {
      color = LightColor(28, 16, 1),
      effect = { components.Light.effects.flicker, { 0.15, 0.3 } },
      falloff = 0.4,
   },
   components.Item(),
   components.Equipment {
      slot = "offhand",
   },
   components.Weapon {
      stat = "ATK",
      name = "Torch",
      dice = "1d1",
      time = 75,
      effects = {
        burnOnHit
      },
      properties = {"melee", "thrown"}
   },
}

return Torch
