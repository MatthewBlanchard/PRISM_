local Component = require "component"

local Sight = Component:extend()
Sight.name = "Sight"

function Sight:__new(options)
  self.range = options.range
  self.fov = options.fov
  
  -- explored tracks tiles that have been seen by the player
  self.explored = options.explored

  -- remembered actors that have been seen by the player
  self.rememberedActors = ROT.Type.Grid:new()

  if options.darkvision and math.floor(options.darkvision) ~= options.darkvision then
    error("Darkvision must be an integer")
  end

  self.darkvision = options.darkvision or 8
end

function Sight:initialize(actor)
  self.seenActors = {}
  self.scryActors = {}

  if self.fov then
    self.fov = {}
    if self.explored then
      self.explored = {}
    end
  end
end

function Sight:getRevealedActors()
  return self.seenActors
end

function Sight:setCellExplored(x, y, explored)
  if self.explored then
    self.explored[x] = self.explored[x] or {}
    self.explored[x][y] = explored
  end
end

function Sight:canSeeCell(x, y)
  return self.fov[x] and self.fov[x][y]
end

return Sight
