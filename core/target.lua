local Object = require("object")
local Vector2 = require("math.vector")
local Actor = require("core.actor")

local targets = {}

local Target = Object:extend()
Target.range = nil
targets.Target = Target

function Target:extend()
<<<<<<< HEAD
   local self = Object.extend(self)

   return self
end

function Target:__new(range)
   self.range = range or self.range
   self.canTargetSelf = false
end

function Target:setRange(range, enum)
   self.range = range
   self.rtype = enum
=======
	local self = Object.extend(self)

	return self
end

function Target:__new(range)
	self.range = range or self.range
	self.canTargetSelf = false
end

function Target:setRange(range, enum)
	self.range = range
	self.rtype = enum
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

function Target:validate(owner, toValidate) end

local ActorTarget = Target:extend()
ActorTarget.rtype = "box"

function ActorTarget:__new(range)
<<<<<<< HEAD
   Target.__new(self, range)
   self.canTargetSelf = false
end

function ActorTarget:validate(owner, actor)
   assert(actor:is(Actor), "Invalid target for ActorTarget")
   local range = false

   if owner == actor and not self.canTargetSelf then return false end

   if not self.range then return true end

   if self.range == 0 then
      local inventory = owner:getComponent(components.Inventory)
      if inventory and inventory:hasItem(actor) then range = true end

      if owner.position == actor.position then range = true end
   else
      range = owner:getRange(self.rtype, actor) <= self.range
   end

   return range
=======
	Target.__new(self, range)
	self.canTargetSelf = false
end

function ActorTarget:validate(owner, actor)
	assert(actor:is(Actor), "Invalid target for ActorTarget")
	local range = false

	if owner == actor and not self.canTargetSelf then
		return false
	end

	if not self.range then
		return true
	end

	if self.range == 0 then
		local inventory = owner:getComponent(components.Inventory)
		if inventory and inventory:hasItem(actor) then
			range = true
		end

		if owner.position == actor.position then
			range = true
		end
	else
		range = owner:getRange(self.rtype, actor) <= self.range
	end

	return range
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local PointTarget = Target:extend()

function PointTarget:validate(owner, vec2)
<<<<<<< HEAD
   if not vec2 or not vec2.is or not vec2:is(Vector2) then return false end
   return owner:getRangeVec(self.rtype, vec2)
end

function PointTarget:checkRequirements(vec2) return vec2.x and vec2.y end
=======
	if not vec2 or not vec2.is or not vec2:is(Vector2) then
		return false
	end
	return owner:getRangeVec(self.rtype, vec2)
end

function PointTarget:checkRequirements(vec2)
	return vec2.x and vec2.y
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

targets.Actor = ActorTarget
targets.Point = PointTarget

targets.Creature = targets.Actor:extend()

function targets.Creature:validate(owner, actor)
<<<<<<< HEAD
   return ActorTarget.validate(self, owner, actor) and actor:hasComponent(components.Stats)
=======
	return ActorTarget.validate(self, owner, actor) and actor:hasComponent(components.Stats)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

targets.Living = targets.Actor:extend()

function targets.Living:validate(owner, actor)
<<<<<<< HEAD
   return targets.Actor.validate(self, owner, actor)
      and actor:hasComponent(components.Stats)
      and actor:hasComponent(components.Controller)
=======
	return targets.Actor.validate(self, owner, actor)
		and actor:hasComponent(components.Stats)
		and actor:hasComponent(components.Controller)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

targets.Item = targets.Actor:extend()

function targets.Item:validate(owner, actor)
<<<<<<< HEAD
   return targets.Actor.validate(self, owner, actor) and actor:hasComponent(components.Item)
=======
	return targets.Actor.validate(self, owner, actor) and actor:hasComponent(components.Item)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

targets.Equipment = targets.Item:extend()

function targets.Equipment:validate(owner, actor)
<<<<<<< HEAD
   local equipper = owner:getComponent(components.Equipper)
   local equipment = actor:getComponent(components.Equipment)
   local hasSlot = equipment and equipper and equipper:hasSlot(equipment.slot) or false
   local slotEmpty = equipment and equipper and equipper:getSlot(equipment.slot) == false

   return targets.Item.validate(self, owner, actor) and hasSlot and slotEmpty
=======
	local equipper = owner:getComponent(components.Equipper)
	local equipment = actor:getComponent(components.Equipment)
	local hasSlot = equipment and equipper and equipper:hasSlot(equipment.slot) or false
	local slotEmpty = equipment and equipper and equipper:getSlot(equipment.slot) == false

	return targets.Item.validate(self, owner, actor) and hasSlot and slotEmpty
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

targets.Weapon = targets.Item:extend()

function targets.Weapon:validate(owner, actor)
<<<<<<< HEAD
   local weapon_component = actor:getComponent(components.Weapon)
   local attacker_component = owner:getComponent(components.Attacker)

   local wielded = attacker_component and attacker_component.wielded == actor or false
   return targets.Item.validate(self, owner, actor) and weapon_component and not wielded
=======
	local weapon_component = actor:getComponent(components.Weapon)
	local attacker_component = owner:getComponent(components.Attacker)

	local wielded = attacker_component and attacker_component.wielded == actor or false
	return targets.Item.validate(self, owner, actor) and weapon_component and not wielded
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

targets.Unequip = targets.Item:extend()
targets.Unequip.range = math.huge -- Target is bounded by being equipped so we can set range to infinite

function targets.Unequip:validate(owner, actor)
<<<<<<< HEAD
   local equipper = owner:getComponent(components.Equipper)
   local equipment = actor:getComponent(components.Equipment)

   local isEquipped = equipment and equipper and equipper.slots[equipment.slot] == actor
   return targets.Item.validate(self, owner, actor) and isEquipped
=======
	local equipper = owner:getComponent(components.Equipper)
	local equipment = actor:getComponent(components.Equipment)

	local isEquipped = equipment and equipper and equipper.slots[equipment.slot] == actor
	return targets.Item.validate(self, owner, actor) and isEquipped
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

targets.Unwield = targets.Item:extend()

function targets.Unwield:validate(owner, actor)
<<<<<<< HEAD
   local weapon_component = actor:getComponent(components.Weapon)
   local attacker = owner:getComponent(components.Attacker)

   local wielded = attacker and attacker.wielded == actor or false
   return targets.Item.validate(self, owner, actor) and weapon_component and wielded
=======
	local weapon_component = actor:getComponent(components.Weapon)
	local attacker = owner:getComponent(components.Attacker)

	local wielded = attacker and attacker.wielded == actor or false
	return targets.Item.validate(self, owner, actor) and weapon_component and wielded
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return targets
