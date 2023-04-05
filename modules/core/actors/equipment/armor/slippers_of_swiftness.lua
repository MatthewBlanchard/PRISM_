local Actor = require "core.actor"
local Tiles = require "display.tiles"

local SlippersOfSwiftness = Actor:extend()
SlippersOfSwiftness.char = Tiles["shoes"]
SlippersOfSwiftness.name = "Slippers of Swiftness"

SlippersOfSwiftness.components = {
  components.Item(),
  components.Equipment{
    slot = "feet",
    effects = {
      conditions.Swiftness
    }
  },
  components.Cost{rarity = "rare"}
}

return SlippersOfSwiftness
