local Cave = require "maps.chunks.cave"
local Clipper = require "maps.clipper.clipper"

local SqeetoHive = Cave:extend()

function SqeetoHive:populater(chunk, clipping)
   local cx, cy = math.floor(chunk.width / 2) + 1, math.floor(chunk.height / 2) + 1

   for i = 1, 3 do
      local x, y
      repeat
         x, y = love.math.random(1, chunk.width - 1) + 1, love.math.random(1, chunk.height - 1) + 1
      until chunk:get_cell(x, y) == 0
      chunk:insert_actor("Sqeeto", x, y)
   end

   chunk:insert_actor("Prism", cx, cy)
end

return SqeetoHive
