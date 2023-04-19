local Component = require("core.component")
local Tiles = require("display.tiles")
local Vector2 = require("math.vector")

local Projectile = Component:extend()
Projectile.name = "Projectile"

function Projectile:__new(options)
<<<<<<< HEAD
   self.range = options.range or 5
   self.traveled = 0
   self.bounce = options.bounce or 0
   self.damage = options.damage or "1d2"
   self.effects = options.effects or {}
   self.direction = options.direction or Vector2.UP
=======
	self.range = options.range or 5
	self.traveled = 0
	self.bounce = options.bounce or 0
	self.damage = options.damage or "1d2"
	self.effects = options.effects or {}
	self.direction = options.direction or Vector2.UP
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Projectile
