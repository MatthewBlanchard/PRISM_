local Actor = require("core.actor")
local Action = require("core.action")
local Tiles = require("display.tiles")

local Gate = Actor:extend()

Gate.char = Tiles["door_3"]
Gate.name = "gate"
Gate.remembered = true

local targetDoor = targets.Actor:extend()

<<<<<<< HEAD
function targetDoor:validate(owner, Gate) return Gate:is(actors.Gate) end
=======
function targetDoor:validate(owner, Gate)
	return Gate:is(actors.Gate)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

local Open = Action:extend()
Open.name = "open"
Open.targets = { targetDoor }

function Open:perform(level)
<<<<<<< HEAD
   local door = self.targetActors[1]

   local collideable = door:hasComponent(components.Collideable)
   door.char = not collideable and Tiles["door_3"] or Tiles["door_1"]

   if collideable then
      level:removeComponent(door, components.Collideable)
   else
      level:addComponent(door, components.Collideable_box())
   end
end

Gate.components = {
   components.Collideable_box(),
   components.Usable({ Open }, Open),
   components.Stats {
      maxHP = 12,
      AC = 0,
   },
=======
	local door = self.targetActors[1]

	local collideable = door:hasComponent(components.Collideable)
	door.char = not collideable and Tiles["door_3"] or Tiles["door_1"]

	if collideable then
		level:removeComponent(door, components.Collideable)
	else
		level:addComponent(door, components.Collideable_box())
	end
end

Gate.components = {
	components.Collideable_box(),
	components.Usable({ Open }, Open),
	components.Stats({
		maxHP = 12,
		AC = 0,
	}),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Gate
