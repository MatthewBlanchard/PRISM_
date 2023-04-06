local Actor = require "core.actor"
local Action = require "core.action"
local Condition = require "core.condition"
local Tiles = require "display.tiles"
local Vector2 = require "math.vector"

local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.targets = {targets.Item}

function Zap:perform(level)
  local effects_system = level:getSystem("Effects")
  actions.Zap.perform(self, level)
  local target = self.targetActors[2]
  local position = self.owner.position

  local x, y = level:getRandomWalkableTile()
  level:moveActor(self.owner, Vector2(x, y))
  effects_system:addEffect(level, effects.Character(x, y, Tiles["poof"], {.4, .4, .4}, 0.3))
end

local WandOfRandomTeleportation = Actor:extend()
WandOfRandomTeleportation.name = "Wand of Displacement"
WandOfRandomTeleportation.color = {0.1, 0.1, .7, 1}
WandOfRandomTeleportation.char = Tiles["wand_pointy"]

WandOfRandomTeleportation.components = {
  components.Item{stackable = false},
  components.Usable(),
  components.Wand{
    maxCharges = 5,
    zap = Zap
  },
  components.Cost{rarity = "uncommon"}
}

return WandOfRandomTeleportation
