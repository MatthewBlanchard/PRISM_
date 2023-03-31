local Chunk = {}
function Chunk:new(width, height)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o:init(width, height, value)
  return o
end
function Chunk:init(width, height)
  function self:parameters()
    self.width = 4
    self.height = 4
  end
  function self:shaper(chunk)
    chunk:clear_rect(1,1, chunk.width-1, chunk.height-1)
  end
  function self:populater(chunk)
    local cx, cy = chunk:get_center()
    chunk:insert_actor('Glowshroom_1', cx, cy)
  end
end

return Chunk