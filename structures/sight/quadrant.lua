local Object = require("object")

Quadrant = Object:extend()

function Quadrant:__new(cardinal, origin)
<<<<<<< HEAD
   self.cardinal = cardinal
   self.ox = origin.x
   self.oy = origin.y
end

function Quadrant:transform(row, col)
   if self.cardinal == 0 then
      return self.ox + col, self.oy - row
   elseif self.cardinal == 1 then
      return self.ox + row, self.oy + col
   elseif self.cardinal == 2 then
      return self.ox + col, self.oy + row
   elseif self.cardinal == 3 then
      return self.ox - row, self.oy + col
   end
=======
	self.cardinal = cardinal
	self.ox = origin.x
	self.oy = origin.y
end

function Quadrant:transform(row, col)
	if self.cardinal == 0 then
		return self.ox + col, self.oy - row
	elseif self.cardinal == 1 then
		return self.ox + row, self.oy + col
	elseif self.cardinal == 2 then
		return self.ox + col, self.oy + row
	elseif self.cardinal == 3 then
		return self.ox - row, self.oy + col
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Quadrant
