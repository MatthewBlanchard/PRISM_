local Actor = require "core.actor"
local Tiles = require "display.tiles"

local Dagger = Actor:extend()
Dagger.char = Tiles["shortsword"]
Dagger.name = "dagger"

Dagger.components = {
  components.Item(),
  components.Weapon{
    stat = "ATK",
    name = "Dagger",
    dice = "1d4",
    time = 50
  },
  components.Cost{}
}

return Dagger
