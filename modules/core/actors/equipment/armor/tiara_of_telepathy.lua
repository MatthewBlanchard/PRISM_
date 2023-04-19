local Actor = require("core.actor")
local Tiles = require("display.tiles")
local Condition = require("core.condition")

local Scrying = Condition:extend()
Scrying.name = "Scrying"
Scrying.damage = 1

Scrying:onScry(function(self, level, actor)
<<<<<<< HEAD
   local scryed = {}
   for actor in level:eachActor(components.Aicontroller) do
      table.insert(scryed, actor)
   end

   return scryed
=======
	local scryed = {}
	for actor in level:eachActor(components.Aicontroller) do
		table.insert(scryed, actor)
	end

	return scryed
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end)

local TiaraOfTelepathy = Actor:extend()
TiaraOfTelepathy.char = Tiles["tiara"]
TiaraOfTelepathy.name = "Tiara of Telepathy"
TiaraOfTelepathy.description =
<<<<<<< HEAD
   "You feel the thoughts of all living things on this floor. Their location becomes clear to you."

TiaraOfTelepathy.components = {
   components.Item(),
   components.Equipment {
      slot = "head",
      effects = {
         conditions.Modifystats {
            MR = 1,
            MGK = 1,
         },
         Scrying,
      },
   },
   components.Cost { rarity = "mythic" },
=======
	"You feel the thoughts of all living things on this floor. Their location becomes clear to you."

TiaraOfTelepathy.components = {
	components.Item(),
	components.Equipment({
		slot = "head",
		effects = {
			conditions.Modifystats({
				MR = 1,
				MGK = 1,
			}),
			Scrying,
		},
	}),
	components.Cost({ rarity = "mythic" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return TiaraOfTelepathy
