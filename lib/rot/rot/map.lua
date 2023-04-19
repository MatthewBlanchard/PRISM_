local ROT = require((...):gsub((".[^./\\]*"):rep(1) .. "$", ""))
<<<<<<< HEAD
local Map = ROT.Class:extend "Map"

function Map:init(width, height)
   self._width = width or ROT.DEFAULT_WIDTH
   self._height = height or ROT.DEFAULT_HEIGHT
=======
local Map = ROT.Class:extend("Map")

function Map:init(width, height)
	self._width = width or ROT.DEFAULT_WIDTH
	self._height = height or ROT.DEFAULT_HEIGHT
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

function Map:create() end

function Map:_fillMap(value)
<<<<<<< HEAD
   local map = {}
   for x = 1, self._width do
      map[x] = {}
      for y = 1, self._height do
         map[x][y] = value
      end
   end
   return map
=======
	local map = {}
	for x = 1, self._width do
		map[x] = {}
		for y = 1, self._height do
			map[x][y] = value
		end
	end
	return map
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Map
