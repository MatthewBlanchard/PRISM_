local Object = require 'object'

local Chunk = Object:extend()

function Chunk:__new(width, height)
  self:init(width, height, value)
end

function Chunk:parameters()
  self.width = 3
  self.height = 3
end

function Chunk:shaper(map)
  chunk:clear_rect(0,0, chunk.width, chunk.height)
end

function Chunk:populater(map)
end

return Chunk