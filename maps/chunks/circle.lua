<<<<<<< HEAD
local Chunk = require "maps.map"
=======
local Chunk = require("maps.map")
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

local Circle = Chunk:extend()
Circle.name = "Circle"

function Circle:parameters()
<<<<<<< HEAD
   self.width = math.random(5, 20)
   self.height = math.random(5, 20)
   self.iterations = math.random(10, 20)
end

function Circle:shaper(map)
   local x, y = map:get_center()

   local max_radius = math.floor(map.width / 2) - 1
   local min_radius = math.floor(map.width / 4) - 1
   local radius = math.random(min_radius, max_radius)

   map:clear_ellipse(x, y, radius, radius)
=======
	self.width = math.random(5, 20)
	self.height = math.random(5, 20)
	self.iterations = math.random(10, 20)
end

function Circle:shaper(map)
	local x, y = map:get_center()

	local max_radius = math.floor(map.width / 2) - 1
	local min_radius = math.floor(map.width / 4) - 1
	local radius = math.random(min_radius, max_radius)

	map:clear_ellipse(x, y, radius, radius)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

function Circle:populater(map, clipping) end

return Circle
