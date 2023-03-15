local Actor = require "actor"
local Tiles = require "tiles"
local Condition = require "condition"

local Read = actions.Read:extend()
Read.name = "read"
Read.targets = {targets.Item}

function Read:perform(level)
    actions.Read.perform(self, level)

    local familiar = actors.Gloop()
    familiar.position.x = self.owner.position.x
    familiar.position.y = self.owner.position.y
    familiar:addComponent(components.Lifetime{duration = 1000})

    local mind_control = conditions.Mind_control()
    familiar:applyCondition(mind_control)

    level:addActor(familiar)
end

local ScrollOfFindFamiliar = Actor:extend()
ScrollOfFindFamiliar.name = "Scroll of Find Familiar"
ScrollOfFindFamiliar.color = {0.8, 0.8, 0.8, 1}
ScrollOfFindFamiliar.char = Tiles["scroll"]

ScrollOfFindFamiliar.components = {
  components.Item(),
  components.Usable(),
  components.Readable{read = Read},
  components.Cost()
}

return ScrollOfFindFamiliar
