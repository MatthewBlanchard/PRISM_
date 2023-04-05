local Actor = require "core.actor"
local Action = require "core.action"
local Tiles = require "display.tiles"

local targetDoor = targets.Actor:extend()

function targetDoor:validate(owner, actor)
  return actor:is(actors.Door)
end

local Open = Action:extend()
Open.name = "open"
Open.targets = {targetDoor}

function Open:perform(level)
  local door = self.targetActors[1]

  local collideable = door:hasComponent(components.Collideable)
  door.char = not collideable and Tiles["door_2"] or Tiles["door_1"]

  if collideable then
    door:removeComponent(components.Collideable_box)
  else
    door:addComponent(components.Collideable_box())
  end

  door.opaque = not collideable
end

local Door = Actor:extend()

Door.char = Tiles["door_2"]
Door.name = "door"
Door.opaque = true
Door.remembered = true

Door.components = {
  components.Collideable_box(),
  components.Usable({Open}, Open),
  components.Stats{
    maxHP = 12,
    AC = 0
  }
}

return Door
