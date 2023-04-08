local Cell = require "cell"
local Tiles = require "tiles"

local River = Cell:extend()
River.name = "River"
River.passable = true
River.opaque = false
River.sightLimit = nil
River.tile = Tiles["river_h_1"]

local vec2 = require 'vector'
function River:onEnter(level, actor)
  local move = actor:getComponent(components.Move)
  if move then
    local move = actions.Move(actor, vec2(0,1))
    level:performAction(move)
  end
end

return River