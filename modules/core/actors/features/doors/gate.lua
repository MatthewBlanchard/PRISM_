local Actor = require "core.actor"
local Action = require "core.action"
local Tiles = require "display.tiles"

local Gate = Actor:extend()

Gate.char = Tiles["door_3"]
Gate.name = "gate"
Gate.remembered = true

local targetDoor = targets.Actor:extend()

function targetDoor:validate(owner, Gate) return Gate:is(actors.Gate) end

local Open = Action:extend()
Open.name = "open"
Open.targets = { targetDoor }

function Open:perform(level)
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
}

return Gate
