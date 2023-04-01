local Chunk = require 'maps.chunk'
local Clipper = require('maps.clipper.clipper')

local Cave = Chunk:extend()

function Cave:parameters()
  self.width = math.random(10, 30)
  self.height = math.random(10, 30)
  self.iterations = math.random(10, 20)
end

function Cave:shaper(chunk)
    local x, y = chunk:get_center()

    local max_radiusx = math.floor(chunk.width / 2) - 1
    local min_radiusx = math.floor(chunk.width / 4) - 1
    local radiusx = math.random(min_radiusx, max_radiusx)

    local max_radiusy = math.floor(chunk.width / 2) - 1
    local min_radiusy = math.floor(chunk.width / 4) - 1
    local radiusy = math.random(min_radiusy, max_radiusy)

    chunk:clear_ellipse(x, y, radiusx, radiusy)
    for i = 1, self.iterations do
        chunk:DLAInOut()
    end
end

function Cave:populater(chunk, clipping)
end

return Cave