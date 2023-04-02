local Actor = require "core.actor"
local Action = require "core.action"
local Tiles = require "display.tiles"

local Read = actions.Read:extend()
Read.name = "read"
Read.targets = {targets.Item}

function Read:perform(level)
  actions.Read.perform(self, level)

  for x = 1, level.width do
	for y = 1, level.height do
	  if not self.owner.explored[x] then self.owner.explored[x] = {} end
	  self.owner.explored[x][y] = level.map:getCell(x, y)
	end
  end
end

local Scroll = Actor:extend()
Scroll.name = "Scroll of Mapping"
Scroll.color = {0.8, 0.8, 0.8, 1}
Scroll.char = Tiles["scroll"]

Scroll.components = {
  components.Item(),
  components.Usable(),
  components.Readable{read = Read},
  components.Cost()
}

return Scroll
