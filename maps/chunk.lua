<<<<<<< HEAD
local Object = require "object"

local Chunk = Object:extend()

function Chunk:__new(width, height) self:init(width, height, value) end

function Chunk:parameters()
   self.width = 4
   self.height = 4
end

function Chunk:shaper(map) chunk:clear_rect(1, 1, chunk.width - 1, chunk.height - 1) end
=======
local Object = require("object")

local Chunk = Object:extend()

function Chunk:__new(width, height)
	self:init(width, height, value)
end

function Chunk:parameters()
	self.width = 4
	self.height = 4
end

function Chunk:shaper(map)
	chunk:clear_rect(1, 1, chunk.width - 1, chunk.height - 1)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

function Chunk:populater(map) end

return Chunk
