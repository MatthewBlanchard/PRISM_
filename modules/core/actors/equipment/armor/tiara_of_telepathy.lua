local Actor = require "core.actor"
local Tiles = require "display.tiles"
local Condition = require "core.condition"

local Scrying = Condition:extend()
Scrying.name = "Scrying"
Scrying.damage = 1

Scrying:onScry(function(self, level, actor)
	local scryed = {}
	for actor in level:eachActor(components.Aicontroller) do
		table.insert(scryed, actor)
	end

	return scryed
end)

local TiaraOfTelepathy = Actor:extend()
TiaraOfTelepathy.char = Tiles["tiara"]
TiaraOfTelepathy.name = "Tiara of Telepathy"
TiaraOfTelepathy.description =
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
}

return TiaraOfTelepathy
