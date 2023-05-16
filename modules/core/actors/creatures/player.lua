local Actor = require "core.actor"
local Condition = require "core.condition"
local Tiles = require "display.tiles"

local Player = Actor:extend()
Player.name = "Player"
Player.char = Tiles["player"]

Player.components = {
   components.Collideable_box(),
   components.Sight { range = 16, fov = true, explored = true },
   components.Message(),
   components.Move { speed = 100 },
   components.Inventory(),
   components.Wallet { autoPick = true },
   components.Controller { inputControlled = true },

   components.Stats {
      ATK = 0,
      MGK = 0,
      PR = 100,
      MR = 0,
      maxHP = 10,
      AC = 0,
   },

   components.Progression(),

   components.Attacker {
      defaultAttack = {
         name = "Stronk Fists",
         stat = "ATK",
         dice = "1d1",
      },
   },

   components.Equipper {
      "body",
      "head",
      "offhand",
      "ring",
      "feet",
      "cloak",
   },

   components.Animated {
      sheet = { Tiles["player_1"], Tiles["player_2"] },
   },

   components.Drawable(),

   components.Faction { "player", "warmblooded" },
}

return Player
