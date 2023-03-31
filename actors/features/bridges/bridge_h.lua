local Actor = require "actor"
local Tiles = require "tiles"

local Bridge = Actor:extend()
Bridge.char = Tiles["bridge_h"]
Bridge.name = "bridge"
Bridge.color = { 128/255, 64/255, 0/255, 1}
Bridge.remembered = true

Bridge.components = {}

return Bridge