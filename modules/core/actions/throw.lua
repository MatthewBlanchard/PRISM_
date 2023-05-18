local Action = require "core.action"
local Bresenham = require "math.bresenham"
local Vector2 = require "math.vector"

local ThrowTarget = targets.Point:extend()
ThrowTarget.name = "throwtarget"
ThrowTarget.range = 6

local Throw = Action:extend()
Throw.name = "throw"
Throw.range = 6
Throw.targets = { targets.Item, ThrowTarget }

function Throw:perform(level)
   local thrown = self.targetActors[1]
   local point = self.targetActors[2]

   local ox, oy = self.owner.position.x, self.owner.position.y
   local px, py = point.x, point.y
   local line, valid = Bresenham.line(ox, oy, px, py)

   local weaponComponent = thrown:getComponent(components.Weapon)
   local thrown_weapon = false
   if weaponComponent and weaponComponent.properties["thrown"] then
      thrown_weapon = true
   end

   local inventoryComponent = self.owner:getComponent(components.Inventory)
   inventoryComponent:removeItem(thrown)
   level:addActor(thrown)

   for i = 2, #line do
      local point = line[i]
      --Check for actor, hit them if a thrown weapon is used
      local potentialHits = level:getActorsAt(point[1], point[2])
      if thrown_weapon == true then
         for _,actor in pairs(potentialHits) do
         local statsComponent = actor:getComponent(components.Stats)
            if statsComponent then
               local attack = actions.Attack(self.owner, actor, thrown)
               level:performAction(attack)
               if attack.hit then
                  level:moveActor(thrown, Vector2(line[i-1][1], line[i-1][2]))
                  return
               end
            end
         end
      end

      if level:getCellPassable(point[1], point[2]) then
         level:moveActor(thrown, Vector2(point[1], point[2]))
         level:yield("wait", 0.1)
      else
         return
      end
   end
end

return Throw
