local Actor = require "core.actor"
local Tiles = require "display.tiles"

local Bridge = Actor:extend()
Bridge.char = Tiles["bridge_v"]
Bridge.name = "bridge"
Bridge.color = { 128/255, 64/255, 0/255, 1}
Bridge.remembered = true

Bridge.components = {}

return Bridge