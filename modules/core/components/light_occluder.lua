local Component = require("core.component")

local LightOccluder = Component:extend()
LightOccluder.name = "LightOccluder"

<<<<<<< HEAD
function LightOccluder:__new(occlusion) self.reduction = occlusion or 1 end
=======
function LightOccluder:__new(occlusion)
	self.reduction = occlusion or 1
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return LightOccluder
