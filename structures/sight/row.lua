local Object = require("object")

Row = Object:extend()

function Row:__new(depth, start_slope, end_slope)
<<<<<<< HEAD
   assert(depth and start_slope and end_slope, "Row:new(depth, start_slope, end_slope)")
   self.depth = depth
   self.start_slope = start_slope
   self.end_slope = end_slope
end

function Row:each_tile()
   local min_col = Row.round_ties_up(self.start_slope * self.depth)
   local max_col = Row.round_ties_down(self.end_slope * self.depth)
   local col = min_col

   return function()
      if col <= max_col then
         col = col + 1
         return self.depth, col - 1
      else
         return nil
      end
   end
end

function Row.round_ties_up(n) return math.floor(n:to_number() + 0.5) end

function Row.round_ties_down(n) return math.ceil(n:to_number() - 0.5) end

function Row:next() return Row(self.depth + 1, self.start_slope, self.end_slope) end
=======
	assert(depth and start_slope and end_slope, "Row:new(depth, start_slope, end_slope)")
	self.depth = depth
	self.start_slope = start_slope
	self.end_slope = end_slope
end

function Row:each_tile()
	local min_col = Row.round_ties_up(self.start_slope * self.depth)
	local max_col = Row.round_ties_down(self.end_slope * self.depth)
	local col = min_col

	return function()
		if col <= max_col then
			col = col + 1
			return self.depth, col - 1
		else
			return nil
		end
	end
end

function Row.round_ties_up(n)
	return math.floor(n:to_number() + 0.5)
end

function Row.round_ties_down(n)
	return math.ceil(n:to_number() - 0.5)
end

function Row:next()
	return Row(self.depth + 1, self.start_slope, self.end_slope)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Row
