<<<<<<< HEAD
local Panel = require "panels.panel"
=======
local Panel = require("panels.panel")
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

local SwirlPanel = Panel:extend()

function SwirlPanel:__new(display, parent)
<<<<<<< HEAD
   Panel.__new(self, display, parent, 1, 1, display:getWidth(), display:getHeight())
   self.time = 0
end

function SwirlPanel:update(dt) self.time = self.time + dt end
=======
	Panel.__new(self, display, parent, 1, 1, display:getWidth(), display:getHeight())
	self.time = 0
end

function SwirlPanel:update(dt)
	self.time = self.time + dt
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

local chars = {}

-- let's define ourselves a little gradient
chars[5] = ROT.Color.multiplyScalar({ 0.67, 0.78, 0.9, 1 }, 1)
chars[4] = ROT.Color.multiplyScalar({ 0.67, 0.78, 0.9, 1 }, 1)
chars[3] = ROT.Color.multiplyScalar({ 0.67, 0.78, 0.9, 1 }, 1 / 1.2)
chars[2] = ROT.Color.multiplyScalar({ 0.67, 0.78, 0.9, 1 }, 1 / 1.5)
chars[1] = ROT.Color.multiplyScalar({ 0.67, 0.78, 0.9, 1 }, 1 / 1.7)
chars[0] = ROT.Color.multiplyScalar({ 0.67, 0.78, 0.9, 1 }, 1 / 2)

function SwirlPanel:draw()
<<<<<<< HEAD
   for x = 1, self.display:getWidth() do
      for y = 1, self.display:getHeight() do
         local char = chars[math.floor(love.math.noise(x / 10, y / 10, self.time) * #chars)]
         self:write(" ", x, y, { 1, 1, 1 }, char)
      end
   end
=======
	for x = 1, self.display:getWidth() do
		for y = 1, self.display:getHeight() do
			local char = chars[math.floor(love.math.noise(x / 10, y / 10, self.time) * #chars)]
			self:write(" ", x, y, { 1, 1, 1 }, char)
		end
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

function SwirlPanel:handleKeypress(key) end

return SwirlPanel
