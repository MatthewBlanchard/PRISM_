local Actor = require("core.actor")
local Action = require("core.action")
local Tiles = require("display.tiles")

local targetDoor = targets.Actor:extend()

<<<<<<< HEAD
function targetDoor:validate(owner, actor) return actor:is(actors.Door) end
=======
function targetDoor:validate(owner, actor)
	return actor:is(actors.Door)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

local Open = Action:extend()
Open.name = "open"
Open.targets = { targetDoor }

function Open:perform(level)
<<<<<<< HEAD
   local door = self.targetActors[1]

   local collideable = door:hasComponent(components.Collideable)
   door.char = not collideable and Tiles["door_2"] or Tiles["door_1"]

   if collideable then
      level:removeComponent(door, components.Opaque)
      level:removeComponent(door, components.Collideable)
   else
      level:addComponent(door, components.Opaque())
      level:addComponent(door, components.Collideable_box())
   end
=======
	local door = self.targetActors[1]

	local collideable = door:hasComponent(components.Collideable)
	door.char = not collideable and Tiles["door_2"] or Tiles["door_1"]

	if collideable then
		level:removeComponent(door, components.Opaque)
		level:removeComponent(door, components.Collideable)
	else
		level:addComponent(door, components.Opaque())
		level:addComponent(door, components.Collideable_box())
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local Door = Actor:extend()

Door.char = Tiles["door_2"]
Door.name = "door"
Door.remembered = true

Door.components = {
<<<<<<< HEAD
   components.Opaque(),
   components.Collideable_box(),
   components.Usable({ Open }, Open),
   components.Stats {
      maxHP = 12,
      AC = 0,
   },
=======
	components.Opaque(),
	components.Collideable_box(),
	components.Usable({ Open }, Open),
	components.Stats({
		maxHP = 12,
		AC = 0,
	}),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Door
