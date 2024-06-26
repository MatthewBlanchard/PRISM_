local Condition = require "core.condition"
local Tiles = require "display.tiles"
local Vector2 = require "math.vector"

local Recall = Condition:extend()
Recall.name = "recall"

Recall:setDuration(2000)

function Recall:setPosition(pos)
   assert(pos.is and pos:is(Vector2), "Expected Vector2, got " .. type(pos))
   self.pos = pos
end

function Recall:onDurationEnd(level, actor)
   if level:getCellPassable(self.pos.x, self.pos.y) then
      actor.position = self.pos
      level:addEffect(
         level,
         effects.Character(self.pos.x, self.pos.y, Tiles["poof"], { 0.4, 0.4, 0.4 }, 0.3)
      )
   end
end

return Recall
