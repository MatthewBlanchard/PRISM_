local Actor = require("core.actor")
local Condition = require("core.condition")
local Tiles = require("display.tiles")

local FreedomOfMovement = Condition:extend()
FreedomOfMovement.name = "FreedomOfMovement"
FreedomOfMovement.description = "You have an 90 move speed and can't be reduced."

<<<<<<< HEAD
FreedomOfMovement:setTime(
   actions.Move,
   function(self, level, actor, action) action.time = math.min(action.time, 90) end
)
=======
FreedomOfMovement:setTime(actions.Move, function(self, level, actor, action)
	action.time = math.min(action.time, 90)
end)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

local JerkinOfGrease = Actor:extend()
JerkinOfGrease.char = Tiles["armor"]
JerkinOfGrease.name = "Mantle of Broken Chains"
JerkinOfGrease.description =
   "Nothing can slow you down with this armor on. You also move a bit faster."

JerkinOfGrease.components = {
<<<<<<< HEAD
   components.Item(),
   components.Equipment {
      slot = "body",
      effects = {
         conditions.Modifystats {
            AC = 2,
            PR = 1,
         },
         FreedomOfMovement(),
      },
   },
   components.Cost { rarity = "rare" },
=======
	components.Item(),
	components.Equipment({
		slot = "body",
		effects = {
			conditions.Modifystats({
				AC = 2,
				PR = 1,
			}),
			FreedomOfMovement(),
		},
	}),
	components.Cost({ rarity = "rare" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return JerkinOfGrease
