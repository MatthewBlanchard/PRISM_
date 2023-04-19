local Actor = require("core.actor")
local Action = require("core.action")
local Tiles = require("display.tiles")

local targetDoor = targets.Actor:extend()

<<<<<<< HEAD
function targetDoor:validate(owner, actor) return actor:is(actors.Door_locked) end
=======
function targetDoor:validate(owner, actor)
	return actor:is(actors.Door_locked)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

local Open = Action:extend()
Open.name = "open"
Open.targets = { targetDoor }

function Open:perform(level)
<<<<<<< HEAD
   local door = self.targetActors[1]

   local message_system = level:getSystem "Message"

   local lock_component = door:getComponent(components.Lock_id)
   if lock_component then
      if lock_component:hasKey(self.owner) then
         door:removeComponent(lock_component)
         local inventory_component = self.owner:getComponent(components.Inventory)
         inventory_component:removeItem(lock_component.key)
      else
         message_system:add(level, "The door is locked!", self.owner)
         return nil
      end
   end

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

	local message_system = level:getSystem("Message")

	local lock_component = door:getComponent(components.Lock_id)
	if lock_component then
		if lock_component:hasKey(self.owner) then
			door:removeComponent(lock_component)
			local inventory_component = self.owner:getComponent(components.Inventory)
			inventory_component:removeItem(lock_component.key)
		else
			message_system:add(level, "The door is locked!", self.owner)
			return nil
		end
	end

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
Door.color = { 0.8, 0.1, 0.1, 1 }
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
   components.Lock_id(),
=======
	components.Opaque(),
	components.Collideable_box(),
	components.Usable({ Open }, Open),
	components.Stats({
		maxHP = 12,
		AC = 0,
	}),
	components.Lock_id(),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Door
