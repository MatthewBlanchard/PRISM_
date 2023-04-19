local System = require("core.system")
local Vector2 = require("math.vector")

local InventorySystem = System:extend()
InventorySystem.name = "Inventory"

function InventorySystem:afterAction(level, actor, action)
<<<<<<< HEAD
   local inventory_component = actor:getComponent(components.Inventory)

   if inventory_component and action:is(reactions.Die) then
      for _, item in pairs(inventory_component.inventory) do
         inventory_component:removeItem(item)
         level:addActor(item)
         level:moveActor(item, Vector2(actor.position.x, actor.position.y))
      end
   end
=======
	local inventory_component = actor:getComponent(components.Inventory)

	if inventory_component and action:is(reactions.Die) then
		for _, item in pairs(inventory_component.inventory) do
			inventory_component:removeItem(item)
			level:addActor(item)
			level:moveActor(item, Vector2(actor.position.x, actor.position.y))
		end
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

-- Handles removing actors that are in the inventory at the time removeActor is called.
function InventorySystem:onActorRemoved(level, actor)
<<<<<<< HEAD
   for _, inventory_component in level:eachActor(components.Inventory) do
      if inventory_component:hasItem(actor) then inventory_component:removeItem(actor) end
   end
=======
	for _, inventory_component in level:eachActor(components.Inventory) do
		if inventory_component:hasItem(actor) then
			inventory_component:removeItem(actor)
		end
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

-- Before the level attempts to move the actor we wanna remove it from the inventory and add it
-- to the level
function InventorySystem:beforeMove(level, actor)
<<<<<<< HEAD
   for _, inventory_component in level:eachActor(components.Inventory) do
      if inventory_component:hasItem(actor) then
         level:addActor(actor)
         inventory_component:removeItem(actor)
         return true
      end
   end
=======
	for _, inventory_component in level:eachActor(components.Inventory) do
		if inventory_component:hasItem(actor) then
			level:addActor(actor)
			inventory_component:removeItem(actor)
			return true
		end
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

-- we need to update the position of all actors in the inventory when
-- the owner moves
function InventorySystem:onMove(level, actor)
<<<<<<< HEAD
   local inventory_component = actor:getComponent(components.Inventory)
   if inventory_component then
      for _, item in pairs(inventory_component.inventory) do
         item.position.x = actor.position.x
         item.position.y = actor.position.y
      end
   end
=======
	local inventory_component = actor:getComponent(components.Inventory)
	if inventory_component then
		for _, item in pairs(inventory_component.inventory) do
			item.position.x = actor.position.x
			item.position.y = actor.position.y
		end
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local dummy = {}
-- We need to tick all actors in the inventory
function InventorySystem:onTick(level)
<<<<<<< HEAD
   for _, inventory_component in level:eachActor(components.Inventory) do
      for _, item in pairs(inventory_component.inventory) do
         for _, condition in ipairs(item:getConditions()) do
            local e = condition:getActionEvents("onTicks", level) or dummy
            for _, event in ipairs(e) do
               event:fire(condition, level, item)
            end
         end
      end
   end
=======
	for _, inventory_component in level:eachActor(components.Inventory) do
		for _, item in pairs(inventory_component.inventory) do
			for _, condition in ipairs(item:getConditions()) do
				local e = condition:getActionEvents("onTicks", level) or dummy
				for _, event in ipairs(e) do
					event:fire(condition, level, item)
				end
			end
		end
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return InventorySystem
