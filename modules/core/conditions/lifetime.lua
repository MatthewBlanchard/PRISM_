local Condition = require("core.condition")
local Tiles = require("display.tiles")

local Lifetime = Condition:extend()
Lifetime.duration = 100
Lifetime.name = "Lifetime"

function Lifetime:onDurationEnd(level, actor)
<<<<<<< HEAD
   local effects_system = level:getSystem "Effects"
   effects_system:addEffect(
      level,
      effects.Character(actor.position.x, actor.position.y, Tiles["poof"], { 0.4, 0.4, 0.4 }, 0.3)
   )
   level:removeActor(actor)
=======
	local effects_system = level:getSystem("Effects")
	effects_system:addEffect(
		level,
		effects.Character(actor.position.x, actor.position.y, Tiles["poof"], { 0.4, 0.4, 0.4 }, 0.3)
	)
	level:removeActor(actor)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Lifetime
