local Actor = require "actor"
local Box = require "box"
local Vector2 = require "vector"
local Tiles = require "tiles"
local Shard = require "actors.other.shard"

local Fink = Actor:extend()

Fink.char = Tiles["fink_1"]
Fink.name = "fink"
Fink.color = {0.596, 0.462, 0.329}

Fink.components = {
  components.Collideable_box(),
  components.Sight{ range = 12, fov = true, explored = false, darkvision = 0.1 },
  components.Move{ speed = 100 },
  components.Stats{
    ATK = 1,
    MGK = 0,
    PR = 0,
    MR = 1,
    maxHP = 7,
    AC = 0
  },

  components.Attacker{
    defaultAttack =
    {
      name = "Dagger",
      stat = "ATK",
      dice = "1d2"
    }
  },

  components.Inventory(),
  components.Aicontroller(),
  components.Animated{
    sheet = {Tiles["fink_1"], Tiles["fink_2"]}
  },
  components.Faction{ "fink", "warmblooded" }
}

function Fink:initialize()
  local inventory_component = self:getComponent(components.Inventory)
  
  for i = 1, math.random(2, 4) do
    inventory_component:addItem(Shard())
  end
end

local actUtil = components.Aicontroller
function Fink:act(level)
  local effect_system = level:getSystem("Effects")

  local target_player = actUtil.closestSeenActorByFaction(self, "player")

  if target_player then
    if target_player:getRange("box", self) <= 1 then
      return self:getAction(actions.Attack)(self, target_player)
    end
    
    local player_hp_percentage = target_player.HP / target_player.maxHP

    if player_hp_percentage < 0.3 then
      if target_player:getRange("box", self) <= 1 then
        return self:getAction(actions.Attack)(self, target_player)
      else
        return actUtil.moveToward(self, target_player)
      end
    end
  end

  return actUtil.moveTowardDarkness(level, self)
end

return Fink