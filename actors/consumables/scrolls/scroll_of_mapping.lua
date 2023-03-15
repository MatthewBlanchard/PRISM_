local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"

local Read = actions.Read:extend()
Read.name = "read"
Read.targets = {targets.Item}

function Read:perform(level)
  actions.Read.perform(self, level)

  local sight_component = self.owner:getComponent(components.Sight)
  if not sight_component then return end

  for x = 1, level.width do
    for y = 1, level.height do
      if not sight_component.explored[x] then sight_component.explored[x] = {} end
      sight_component.explored[x][y] = level.map[x][y]
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
