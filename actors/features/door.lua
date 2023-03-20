local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"

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
  door.char = not collideable and Tiles["door_closed"] or Tiles["door_open"]

  if collideable then
    door:removeComponent(components.Collideable)
  else
    door:addComponent(components.Collideable_box())
  end

  door.blocksVision = not collideable
end

local Door = Actor:extend()

Door.char = Tiles["door_closed"]
Door.name = "door"
Door.blocksVision = true
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
