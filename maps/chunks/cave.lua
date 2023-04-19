local Chunk = require "maps.map"
local Clipper = require "maps.clipper.clipper"

local Cave = Chunk:extend()
Cave.name = "Cave"

function Cave:parameters()
   self.width = math.random(10, 20)
   self.height = math.random(10, 20)
   self.iterations = math.random(10, 20)
end

function Cave:shaper(map)
   local x, y = map:get_center()

   local max_radiusx = math.floor(map.width / 2) - 1
   local min_radiusx = math.floor(map.width / 4) - 1
   local radiusx = math.random(min_radiusx, max_radiusx)

   local max_radiusy = math.floor(map.width / 2) - 1
   local min_radiusy = math.floor(map.width / 4) - 1
   local radiusy = math.random(min_radiusy, max_radiusy)

   map:clear_ellipse(x, y, radiusx, radiusy)
   for i = 1, self.iterations do
      map:DLAInOut()
   end
end

function Cave:populater(map, clipping) end

return Cave
