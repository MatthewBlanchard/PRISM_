local Object = require("object")

local BoundingBox = Object:extend()

function BoundingBox:__new(x, y, i, j)
<<<<<<< HEAD
   self.x = x
   self.y = y
   self.i = i
   self.j = j
end

function BoundingBox:getWidth() return self.i - self.x + 1 end

function BoundingBox:getHeight() return self.j - self.y + 1 end

function BoundingBox:contains(x, y)
   return x >= self.x and x <= self.i and y >= self.y and y <= self.j
end

function BoundingBox:intersects(other)
   return not (self.i < other.x or self.x > other.i or self.j < other.y or self.y > other.j)
end

function BoundingBox:union(other)
   local x = math.min(self.x, other.x)
   local y = math.min(self.y, other.y)
   local i = math.max(self.i, other.i)
   local j = math.max(self.j, other.j)
   return BoundingBox(x, y, i, j)
end

function BoundingBox:overlaps_point_box(x, y, hw)
   local point_box_x1, point_box_y1 = x - hw, y - hw
   local point_box_x2, point_box_y2 = x + hw, y + hw

   return not (
      self.i < point_box_x1
      or self.x > point_box_x2
      or self.j < point_box_y1
      or self.y > point_box_y2
   )
end

function BoundingBox:__tostring()
   return string.format("BoundingBox(x=%d, y=%d, i=%d, j=%d)", self.x, self.y, self.i, self.j)
=======
	self.x = x
	self.y = y
	self.i = i
	self.j = j
end

function BoundingBox:getWidth()
	return self.i - self.x + 1
end

function BoundingBox:getHeight()
	return self.j - self.y + 1
end

function BoundingBox:contains(x, y)
	return x >= self.x and x <= self.i and y >= self.y and y <= self.j
end

function BoundingBox:intersects(other)
	return not (self.i < other.x or self.x > other.i or self.j < other.y or self.y > other.j)
end

function BoundingBox:union(other)
	local x = math.min(self.x, other.x)
	local y = math.min(self.y, other.y)
	local i = math.max(self.i, other.i)
	local j = math.max(self.j, other.j)
	return BoundingBox(x, y, i, j)
end

function BoundingBox:overlaps_point_box(x, y, hw)
	local point_box_x1, point_box_y1 = x - hw, y - hw
	local point_box_x2, point_box_y2 = x + hw, y + hw

	return not (self.i < point_box_x1 or self.x > point_box_x2 or self.j < point_box_y1 or self.y > point_box_y2)
end

function BoundingBox:__tostring()
	return string.format("BoundingBox(x=%d, y=%d, i=%d, j=%d)", self.x, self.y, self.i, self.j)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return BoundingBox
