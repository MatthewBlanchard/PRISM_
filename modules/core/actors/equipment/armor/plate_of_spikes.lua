local Actor = require("core.actor")
local Tiles = require("display.tiles")
local Condition = require("core.condition")

local OnHitRecieved = Condition:extend()
OnHitRecieved.name = "OnHitRecieved"

OnHitRecieved:afterAction(actions.Attack, function(self, level, actor, action)
	local defender = action:getTarget(1)
	local attacker = action.owner
	if action.hit and defender == actor then
		local damage = attacker:getReaction(reactions.Damage)(attacker, { defender }, 1, defender)
		level:performAction(damage)
	end
end):where(Condition.ownerIsTarget)

local PlateOfSpikes = Actor:extend()
PlateOfSpikes.char = Tiles["armor"]
PlateOfSpikes.name = "Plate of Prickles"

PlateOfSpikes.components = {
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
}

return PlateOfSpikes
