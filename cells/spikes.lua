local Cell = require "cell"
local Tiles = require "tiles"

local Spikes = Cell:extend()
Spikes.name = "Spikes"
Spikes.passable = true
Spikes.opaque = false
Spikes.sightLimit = nil
Spikes.tile = Tiles["spikes_1"]

function Spikes:onEnter(level, actor) -- called when an actor enters the cell
  local stats = actor:getComponent(components.Stats)
  if stats then
    local damage = 1
    local damage = actor:getReaction(reactions.Damage)(actor, {}, damage)
    level:performAction(damage)
  end
end

return Spikes