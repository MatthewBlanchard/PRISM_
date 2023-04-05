local Action = require "core.action"

local Wait = Action:extend()
Wait.name = "Wait"
Wait.silent = true

function Wait:__new(owner)
  Action.__new(self, owner, {})
end

function Wait:perform(level)
end

return Wait
