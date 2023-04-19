local Actor = require("core.actor")
local Action = require("core.action")
local Tiles = require("display.tiles")

local targetStair = targets.Actor:extend()

<<<<<<< HEAD
function targetStair:validate(owner, actor) return actor:is(actors.Stairs) end
=======
function targetStair:validate(owner, actor)
	return actor:is(actors.Stairs)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

local Exit = Action:extend()
Exit.name = "descend"
Exit.targets = { targetStair }

<<<<<<< HEAD
function Exit:perform(level) level.exit = true end
=======
function Exit:perform(level)
	level.exit = true
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

local Stairs = Actor:extend()

Stairs.char = Tiles["stairs"]
Stairs.name = "stairs"
Stairs.remembered = true

Stairs.components = {
<<<<<<< HEAD
   components.Collideable_box(),
   components.Usable({ Exit }, Exit),
=======
	components.Collideable_box(),
	components.Usable({ Exit }, Exit),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Stairs
