local Actor = require "core.actor"
local Tiles = require "display.tiles"

local Longsword = Actor:extend()
Longsword.char = Tiles["shortsword"]
Longsword.name = "longsword"

Longsword.components = {
  components.Item(),
  components.Weapon{
    stat = "ATK",
    name = "Longsword",
    dice = "1d8",
    time = 100
  },
  components.Cost{}
}

return Longsword
