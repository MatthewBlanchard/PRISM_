local Action = require "core.action"
local Bresenham = require "math.bresenham"
local Vector2 = require "math.vector"

local ThrowTarget = targets.Point:extend()
ThrowTarget.name = "throwtarget"
ThrowTarget.range = 6

local Throw = Action:extend()
Throw.name = "throw"
Throw.range = 6
Throw.targets = {targets.Item, ThrowTarget}

function Throw:perform(level)
  local thrown = self.targetActors[1]
  local point = self.targetActors[2]

  local ox, oy = self.owner.position.x, self.owner.position.y
  local px, py = point.x, point.y
  local line, valid = Bresenham.line(ox, oy, px, py)

  for i = 2, #line do
    local point = line[i]
    if level:getCellPassable(point[1], point[2]) then
      level:moveActor(thrown, Vector2(point[1], point[2]))
      coroutine.yield("wait", 0.1)
    else
      return
    end
  end
end

return Throw
