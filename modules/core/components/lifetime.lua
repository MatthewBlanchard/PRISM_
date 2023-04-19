local Component = require("core.component")

--- THe lifetime component is a simple utility component that applies a lifetime condition to an actor,
--- removing it at the end of the duration.
local Lifetime = Component:extend()
Lifetime.name = "Lifetime"

<<<<<<< HEAD
function Lifetime:__new(options) self.duration = options.duration end

function Lifetime:initialize(actor)
   local customLifetime = conditions.Lifetime:extend()
   customLifetime:setDuration(self.duration)

   actor:applyCondition(customLifetime)
=======
function Lifetime:__new(options)
	self.duration = options.duration
end

function Lifetime:initialize(actor)
	local customLifetime = conditions.Lifetime:extend()
	customLifetime:setDuration(self.duration)

	actor:applyCondition(customLifetime)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Lifetime
