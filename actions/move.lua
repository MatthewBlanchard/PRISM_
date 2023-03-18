local Action = require "action"

local Move = Action:extend()
Move.name = "move"
Move.silent = true
Move.targets = {targets.Point}

function Move:__new(owner, direction)
  Action.__new(self, owner, { direction })
end

function Move:perform(level)
  local direction = self:getTarget(1)

  local newPosition = self.owner.position + direction

  for cell in level:eachActorTile(self.owner) do
    local check = cell + direction
    if not level:getCellPassable(check.x, check.y, self.owner) then
      print(self.owner.name, "YEP")
      return
    end
  end

  level:moveActor(self.owner, newPosition)
end

return Move
