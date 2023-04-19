local Component = require("core.component")

local Animated = Component:extend()
Animated.name = "Animated"

function Animated:__new(options)
<<<<<<< HEAD
   options = options or {}
   self.sheet = options.sheet
=======
	options = options or {}
	self.sheet = options.sheet
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Animated
