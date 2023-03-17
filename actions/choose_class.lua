local Action = require "action"

local ChooseClass = Action:extend()
ChooseClass.time = 0
ChooseClass.silent = true

function ChooseClass:__new(owner, class)
  Action.__new(self, owner)
  self.class = class
end

function ChooseClass:perform(level)
  local actor = self.owner

  actor:addComponent(self.class())
end

return ChooseClass