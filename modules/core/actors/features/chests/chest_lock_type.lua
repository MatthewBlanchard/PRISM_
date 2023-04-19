local Actor = require "core.actor"
local Action = require "core.action"
local Tiles = require "display.tiles"

local targetDoor = targets.Actor:extend()

function targetDoor:validate(owner, actor) return actor:is(actors.Chest_lock_type) end

local Open = Action:extend()
Open.name = "open"
Open.targets = { targetDoor }
Open.silent = true

function Open:perform(level)
	local chest = self.targetActors[1]

	local effects_system = level:getSystem "Effects"
	local message_system = level:getSystem "Message"

	local lock_component = chest:getComponent(components.Lock_type)
	if lock_component then
		if lock_component:hasKey(self.owner) then
			local inventory_component = self.owner:getComponent(components.Inventory)
			inventory_component:removeItemType(lock_component.key)
		else
			message_system:add(level, "The chest is locked!", self.owner)
			return nil
		end
	end

	level:removeActor(chest)

	local message = "You open the chest"
	if chest.key then message = "You unlock the chest" end

	local inventory = chest:getComponent(components.Inventory)
	local item = inventory.inventory[1]
	if item then
		item.position.x = chest.position.x
		item.position.y = chest.position.y
		level:addActor(item)
		-- TODO: Make sure the name is formatted correctly
		message = message .. " and find a " .. item.name .. "!"
	else
		message = message .. "."
	end

	message_system:add(level, message, self.owner)
	effects_system:addEffect(level, effects.OpenEffect(chest))
end

local Chest = Actor:extend()
Chest.char = Tiles["chest"]
Chest.color = { 0.8, 0.8, 0.1, 1 }
Chest.name = "chest"
Chest.remembered = true

Chest.components = {
	components.Collideable_box(),
	components.Usable({ Open }, Open),
	components.Inventory(),
	components.Lock_type(),
}

return Chest
