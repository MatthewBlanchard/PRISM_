local Actor = require "core.actor"
local Action = require "core.action"
local Condition = require "core.condition"
local Tiles = require "display.tiles"

local ZapTarget = targets.Actor:extend()
ZapTarget.name = "ZapTarget"
ZapTarget.requirements = { components.Stats }
ZapTarget.range = 6

local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.targets = { targets.Item, ZapTarget }

function Zap:perform(level)
   actions.Zap.perform(self, level)
   local target = self.targetActors[2]
   target:applyCondition(conditions.Lethargy())
end

local WandOfLethargy = Actor:extend()
WandOfLethargy.name = "Wand of Lethargy"
WandOfLethargy.color = { 0.7, 0.1, 0.7, 1 }
WandOfLethargy.char = Tiles["wand_pointy"]

WandOfLethargy.components = {
   components.Item { stackable = false },
   components.Usable(),
   components.Wand {
      maxCharges = 5,
      zap = Zap,
   },
   components.Cost { rarity = "common" },
}

return WandOfLethargy
