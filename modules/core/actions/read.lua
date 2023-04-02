local Action = require "core.action"
local Consume = require "modules.core.actions.consume"

local Read = Consume:extend()
Read.name = "eat"
Read.targets = {targets.Item}

function Read:perform(level)
  Consume.perform(self, level)
end

return Read
