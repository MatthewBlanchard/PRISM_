local Actor = require "core.actor"
local Tiles = require "display.tiles"

local Greatsword = Actor:extend()
Greatsword.char = Tiles["shortsword"]
Greatsword.name = "greatsword"

Greatsword.components = {
  components.Item(),
  components.Weapon{
    stat = "ATK",
    name = "Greatsword",
    dice = "2d6",
    time = 150
  },
  components.Cost{}
}

return Greatsword
