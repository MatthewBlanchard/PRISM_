local Actor = require("core.actor")
local Tiles = require("display.tiles")
local Condition = require("core.condition")

local OnHitRecieved = Condition:extend()
OnHitRecieved.name = "OnHitRecieved"

OnHitRecieved:afterAction(actions.Attack, function(self, level, actor, action)
<<<<<<< HEAD
   local defender = action:getTarget(1)
   local attacker = action.owner
   if action.hit and defender == actor then
      local damage = attacker:getReaction(reactions.Damage)(attacker, { defender }, 1, defender)
      level:performAction(damage)
   end
=======
	local defender = action:getTarget(1)
	local attacker = action.owner
	if action.hit and defender == actor then
		local damage = attacker:getReaction(reactions.Damage)(attacker, { defender }, 1, defender)
		level:performAction(damage)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end):where(Condition.ownerIsTarget)

local PlateOfSpikes = Actor:extend()
PlateOfSpikes.char = Tiles["armor"]
PlateOfSpikes.name = "Plate of Prickles"

PlateOfSpikes.components = {
<<<<<<< HEAD
   components.Item(),
   components.Equipment {
      slot = "body",
      effects = {
         OnHitRecieved,
         conditions.Modifystats {
            AC = 4,
            PR = 1,
         },
      },
   },
   components.Cost { rarity = "rare" },
=======
	components.Item(),
	components.Equipment({
		slot = "body",
		effects = {
			OnHitRecieved,
			conditions.Modifystats({
				AC = 4,
				PR = 1,
			}),
		},
	}),
	components.Cost({ rarity = "rare" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return PlateOfSpikes
