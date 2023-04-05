local Actor = require "core.actor"
local Action = require "core.action"
local Condition = require "core.condition"
local Tiles = require "display.tiles"

local ZapTarget = targets.Actor:extend()
ZapTarget.name = "MindControlTarget"
ZapTarget.requirements = {components.Aicontroller}
ZapTarget.range = 6

function ZapTarget:validate(owner, actor)
    return targets.Actor.validate(self, owner, actor) and actor:hasComponent(components.Aicontroller)
end

local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.targets = {targets.Item, ZapTarget}

function Zap:perform(level)
  actions.Zap.perform(self, level)
  local target = self.targetActors[2]
  target:applyCondition(conditions.Mind_control())
end

local WandOfMindControl = Actor:extend()
WandOfMindControl.name = "Wand of Mind Control"
WandOfMindControl.color = {0.7, 0.1, 0.7, 1}
WandOfMindControl.char = Tiles["wand_pointy"]

WandOfMindControl.components = {
  components.Item{stackable = false},
  components.Usable(),
  components.Wand{
    maxCharges = 5,
    zap = Zap
  },
  components.Cost{rarity = "mythic"}
}

return WandOfMindControl
