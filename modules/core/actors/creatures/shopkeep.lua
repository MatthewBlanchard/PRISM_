local Actor = require "core.actor"
local Tiles = require "display.tiles"

local Shopkeep = Actor:extend()
Shopkeep.name = "Shopkeep"
Shopkeep.char = Tiles["shop_1"]
Shopkeep.color = {0.5, 0.5, 0.8}

Shopkeep.components = {
    components.Collideable_box(),
}

return Shopkeep
