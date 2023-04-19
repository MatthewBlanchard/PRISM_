local Object = require "object"

-- A simple grid class that stores data in a single contiguous array.
Grid = Object:extend()

function Grid:__new(x, y, initialValue)
	self.x = x
	self.y = y
	self.data = {}
	for i = 1, x * y do
		self.data[i] = initialValue
	end
	return self
end

function Grid:fromData(x, y, data)
	assert(#data == x * y, "Data length does not match grid size.")

	self.x = x
	self.y = y
	self.data = data
	return self
end

function Grid:getIndex(x, y)
	if x < 1 or x > self.x or y < 1 or y > self.y then return nil end

	return (y - 1) * self.x + x
end

function Grid:set(x, y, value)
	local index = self:getIndex(x, y)
	if index then
		self.data[index] = value
	else
		error("Index out of bounds: " .. x .. ", " .. y)
	end
end

function Grid:get(x, y)
	local index = self:getIndex(x, y)
	if index then return self.data[index] end
	return nil
end

function Grid:fill(value)
	for i = 1, #self.data do
		self.data[i] = value
	end
end

return Grid
