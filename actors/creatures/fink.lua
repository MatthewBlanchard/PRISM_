local Actor = require "actor"
local Vector2 = require "vector"
local Tiles = require "tiles"

local Fink = Actor:extend()

Fink.char = Tiles["fink"]
Fink.name = "fink"
Fink.color = {0.596, 0.462, 0.329}
Fink.passable = false

Fink.components = {
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

  components.Aicontroller(),
  components.Animated(),
  components.Faction{ "fink", "warmblooded" }
}

local actUtil = components.Aicontroller
function Fink:act(level)
    return actUtil.moveTowardDarkness(level, self)
end

return Fink