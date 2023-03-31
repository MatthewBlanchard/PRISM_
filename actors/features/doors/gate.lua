local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"

local actor = Actor:extend()

actor.char = Tiles["door_3"]
actor.name = "gate"
actor.opaque = false
actor.remembered = true

local targetDoor = targets.Actor:extend()

function targetDoor:validate(owner, actor)
  return actor:is(actors.Gate)
end

local Open = Action:extend()
Open.name = "open"
Open.targets = {targetDoor}

function Open:perform(level)
  local door = self.targetActors[1]

  local collideable = door:hasComponent(components.Collideable)
  door.char = not collideable and Tiles["door_3"] or Tiles["door_1"]

  if collideable then
    door:removeComponent(components.Collideable)
  else
    door:addComponent(components.Collideable_box())
  end

  door.opaque = not collideable
end



actor.components = {
  components.Collideable_box(),
  components.Usable({Open}, Open),
  components.Stats{
    maxHP = 12,
    AC = 0
  }
}

return actor