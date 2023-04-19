local Actor = require "core.actor"
local Action = require "core.action"
local Tiles = require "display.tiles"

local Arrow = Actor:extend()
Arrow.name = "arrow"
Arrow.char = Tiles["arrow"]
Arrow.color = { 0.8, 0.5, 0.1, 1 }

Arrow.components = {
   components.Item { stackable = true },
}

return Arrow
