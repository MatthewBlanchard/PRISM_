local Actor = require("core.actor")
local Tiles = require("display.tiles")

local poisonOnHit = conditions.Onhit:extend()

<<<<<<< HEAD
function poisonOnHit:onHit(level, attacker, defender) defender:applyCondition(conditions.Poisoned) end
=======
function poisonOnHit:onHit(level, attacker, defender)
	defender:applyCondition(conditions.Poisoned)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

local Dagger_of_Venom = Actor:extend()
Dagger_of_Venom.char = Tiles["dagger"]
Dagger_of_Venom.name = "Dagger of Venom"
Dagger_of_Venom.description = "Inflicts a dangerous poison on your enemies!"
Dagger_of_Venom.color = { 0.1, 1, 0.1 }

Dagger_of_Venom.components = {
<<<<<<< HEAD
   components.Item(),
   components.Weapon {
      stat = "ATK",
      name = "Dagger of Venom",
      dice = "1d4",
      bonus = 1,
      time = 75,
      effects = {
         poisonOnHit,
      },
   },
   components.Cost { rarity = "uncommon" },
=======
	components.Item(),
	components.Weapon({
		stat = "ATK",
		name = "Dagger of Venom",
		dice = "1d4",
		bonus = 1,
		time = 75,
		effects = {
			poisonOnHit,
		},
	}),
	components.Cost({ rarity = "uncommon" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Dagger_of_Venom
