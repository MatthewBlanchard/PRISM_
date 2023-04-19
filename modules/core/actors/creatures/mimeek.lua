local Actor = require("core.actor")
local Action = require("core.action")
local Tiles = require("display.tiles")
local LightColor = require("structures.lighting.lightcolor")

local targetMimeek = targets.Actor:extend()

function targetMimeek:validate(owner, actor)
	return actor:is(actors.Mimeek)
end

local Open = Action:extend()
Open.name = "open"
Open.targets = { targetMimeek }
Open.silent = true

function Open:perform(level)
	local chest = self.targetActors[1]

	local effects_system = level:getSystem("Effects")
	local message_system = level:getSystem("Message")

	level:removeActor(chest)

	for _, item in pairs(chest:getComponent(components.Inventory).inventory) do
		level:addActor(item)
	end

	message_system:add(level, message, self.owner)
	effects_system:addEffect(level, effects.OpenEffect(chest))
end

local Mimeek = Actor:extend()
Mimeek.char = Tiles["chest"]
Mimeek.color = { 0.8, 0.8, 0.1, 1 }
Mimeek.name = "Mimeek"
Mimeek.remembered = true

Mimeek.components = {
	components.Sight({ range = 5, fov = true, explored = false }),
	components.Collideable_box(),
	components.Usable({ Open }, Open),
	components.Inventory(),
	components.Move({ speed = 110 }),
	components.Aicontroller(),
	components.Light({
		color = LightColor(25, 25, 3),
	}),
}

function Mimeek:initialize()
	local inventory_component = self:getComponent(components.Inventory)

	for i = 1, math.random(2, 4) do
		inventory_component:addItem(actors.Shard())
	end

	inventory_component:addItem(actors.Ring_of_bling())
end

local actUtil = components.Aicontroller
function Mimeek:act(level)
	local target = actUtil.closestSeenActorByType(self, actors.Player)

	local effects_system = level:getSystem("Effects")
	if target then
		effects_system:addEffectAfterAction(
			effects.CharacterDynamic(self, 0, -1, Tiles["bubble_lines"], { 1, 1, 1 }, 0.5)
		)
		return actUtil.moveAway(self, target, true)
	end

	return actUtil.randomMove(level, self)
end

return Mimeek
