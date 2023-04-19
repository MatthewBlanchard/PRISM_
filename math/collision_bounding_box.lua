local Object = require("object")
local Vector2 = require("math.vector")

-- A bounding box with a 0, 0 origin for the collision system.
local BoundingBox = Object:extend()

<<<<<<< HEAD
function BoundingBox:__new(size) self.size = size end
=======
function BoundingBox:__new(size)
	self.size = size
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

-- This is an iterator that returns all tiles that are occupied by this
-- bounding box. The cells are in local space (relative to the actor's
-- position). The iterator returns the x and y coordinates of the cell.
-- The first return should be 0, 0.
function BoundingBox:eachCell(position)
<<<<<<< HEAD
   local i, j = 0, 0
   return function()
      for x = i, self.size - 1 do
         for y = j, self.size - 1 do
            i, j = x + 1, y + 1
            return Vector2(x, y) + position
         end
      end
   end
=======
	local i, j = 0, 0
	return function()
		for x = i, self.size - 1 do
			for y = j, self.size - 1 do
				i, j = x + 1, y + 1
				return Vector2(x, y) + position
			end
		end
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return BoundingBox
