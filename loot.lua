local componentCost = {
   [components.Weapon] = 10,
   [components.Wand] = 12,
   [components.Edible] = 3,
   [components.Drinkable] = 5,
   [components.Readable] = 7,
   [components.Equipment] = 15,
}

local rarityModifier = {
   common = 1,
   uncommon = 2,
   rare = 3,
   mythic = 4,
}

local lootUtil = {}

function lootUtil.generateBasePrice(actor)
   local price = 0
   local rarity = 1

   for k, v in pairs(componentCost) do
      if actor:hasComponent(k) then price = price + v end
   end

   local cost = actor:getComponent(components.Cost)
   if cost then rarity = rarityModifier[cost.rarity] end

   return price * rarity
end

function lootUtil.generateLoot(comp, rarity)
   local found = {}
   local rarity = rarity or "common"
   local rarityMod = rarityModifier[rarity]

   for k, actor in pairs(actors) do
      local costComponent = actor:getComponent(components.Cost)
      if
         costComponent
         and rarityModifier[costComponent.rarity] <= rarityMod
         and actor:hasComponent(comp)
      then
         table.insert(found, actor)
      end
   end

   return found[love.math.random(1, #found)]()
end

return lootUtil
