local Actor = require "actor"
local LizBop = Actor:extend()
local Tiles = require "tiles"

LizBop.name = "Lizard"
LizBop.char = Tiles["lizbop_1"]
LizBop.color = {0.0, 1.0, 0.0}

LizBop.actions = {
  actions.Tongue
}

LizBop.components = {
  components.Collideable_box(),
  components.Sight {fov = true, range = 6, expored = false},
  components.Move {speed = 90},
  components.Stats {
      ATK = 1,
      MGK = 0,
      PR = 0,
      MR = 0,
      maxHP = 3,
      AC = 1
  },
  components.Aicontroller(),
  components.Inventory(),
  components.Attacker{
      defaultAttack =
      {
        name = "Tail Swipe",
        stat = "ATK",
        dice = "1d2",
      }
  },
  components.Animated{
    sheet = {Tiles["lizbop_1"], Tiles["lizbop_2"]}
  },
  components.Faction{ "reptile" }
}

local actUtil = components.Aicontroller

function LizBop:act(level)
  local target
  local sqeeter = actUtil.closestSeenActorByType(self, actors.Sqeeto)
  local webweaver = actUtil.closestSeenActorByType(self, actors.Webweaver)
  local player = actUtil.closestSeenActorByType(self, actors.Player)

  if webweaver then
    target = webweaver
  elseif sqeeter then
    target = sqeeter
  end

  if player and player:getRange("box", self) == 1 then
    return self:getAction(actions.Attack)(self, player)
    end

  if target then
    local targetRange = target:getRange("box", self)
    if targetRange == 1 then
      return self:getAction(actions.Attack)(self, target)
    elseif targetRange > 1 and targetRange < 5 then
      return self:getAction(actions.Tongue)(self, {target})
    elseif targetRange >= 5 then
      return actUtil.moveToward(self, target)
    end
  end
  
  return actUtil.randomMove(level, self)
end

return LizBop