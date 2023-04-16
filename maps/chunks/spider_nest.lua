local Chunk = require 'maps.chunk'

local spider_nest = Chunk:extend()
function spider_nest:parameters()
  self.width, self.height = 20, 20
end
function spider_nest:shaper(chunk)
  local cx, cy = chunk:get_center()
  for i = 1, 2 do
    local path = chunk:drunkWalk(cx, cy,
      function(x, y, i, chunk)  
        return (i > 10) or (x < 5 or x > chunk.width-5 or y < 5 or y > chunk.height-5)
      end
    )
  
    chunk:clear_path(path)
  end

  for i = 1, 20 do
    chunk:DLA()
  end
end
function spider_nest:populater(chunk, clipping)
  local cx, cy = chunk:get_center()

  for i = 1, 1 do
    local x, y
    repeat
      x, y = love.math.random(1, chunk.width-1)+1, love.math.random(1, chunk.height-1)+1
    until chunk:get_cell(x, y) == 0
    chunk:insert_actor('Webweaver', x, y)
  end

  for i = 1, 2 do
    local x, y
    repeat
      x, y = love.math.random(1, chunk.width-1)+1, love.math.random(1, chunk.height-1)+1
    until chunk:get_cell(x, y) == 0
    chunk:insert_actor('Web', x, y)
  end

  for i = 1, 2 do
    local x, y
    repeat
      x, y = love.math.random(1, chunk.width-1)+1, love.math.random(1, chunk.height-1)+1
    until chunk:get_cell(x, y) == 0

    if love.math.random(0, 1) == 1 then
      chunk:insert_actor('Bones_1', x, y)
    else
      chunk:insert_actor('Bones_2', x, y)
    end
  end

  for x, y, cell in chunk:for_cells() do
    -- print(x, y)
    -- if cell == 1 then
    --   if love.math.random(0, 1) == 1 then
    --     chunk:insert_actor('Rocks_1', x, y)
    --   else
    --     chunk:insert_actor('Rocks_2', x, y)
    --   end
    -- end
  end

end

return spider_nest