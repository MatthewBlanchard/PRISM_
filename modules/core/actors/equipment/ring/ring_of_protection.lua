local Actor = require "core.actor"
local Tiles = require "display.tiles"

local RingOfProtection = Actor:extend()
RingOfProtection.char = Tiles["ring"]
RingOfProtection.name = "Ring of Protection"

RingOfProtection.components = {
   components.Item(),
   components.Equipment {
      slot = "ring",
      effects = {
         conditions.Modifystats {
            AC = 1,
            PR = 1,
            MR = 1,
         },
      },
   },
   components.Cost { rarity = "uncommon" },
}

return RingOfProtection
