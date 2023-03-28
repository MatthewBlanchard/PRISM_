local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"

local targetDoor = targets.Actor:extend()

function targetDoor:validate(owner, actor)
  return actor:is(actors.Door_locked)
end

local Open = Action:extend()
Open.name = "open"
Open.targets = {targetDoor}

function Open:perform(level)
  local door = self.targetActors[1]

  local message_system = level:getSystem("Message")

  local lock_component = door:getComponent(components.Lock_id)
  if lock_component then
    if lock_component:hasKey(self.owner) then
      door:removeComponent(lock_component)
      level:removeActor(lock_component.key)
    else
      message_system:add(level, "The door is locked!", self.owner)
      return nil
    end
  end

  local collideable = door:hasComponent(components.Collideable)
  door.char = not collideable and Tiles["door_2"] or Tiles["door_1"]

  if collideable then
    door:removeComponent(components.Collideable)
  else
    door:addComponent(components.Collideable_box())
  end

  door.blocksVision = not collideable
end

local Door = Actor:extend()

Door.char = Tiles["door_2"]
Door.name = "door"
Door.color = {0.8, 0.1, 0.1, 1}
Door.blocksVision = true
Door.remembered = true

Door.components = {
  components.Collideable_box(),
  components.Usable({Open}, Open),
  components.Stats{
    maxHP = 12,
    AC = 0
  },
  components.Lock_id()
}

return Door
