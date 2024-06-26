-- Rewrite this in it's entirely.
-- Some of the behaviors here are probably fine for simple enemies, but for more complex enemies, this is not going to cut it.

local Actor = require "core.actor"
local Component = require "core.component"
local Vector2 = require "math.vector"

local AIController = Component:extend()
AIController.name = "AIController"

function AIController:__new(options) self.act = options and options.act or self.act end

function AIController:initialize(actor) actor.act = self.act end

function AIController.isPassable(actor, vec)
   local sight_component = actor:getComponent(components.Sight)
   if not sight_component then return false end

   local cell = sight_component.fov:get(vec.x, vec.y)
   if not cell then return false end

   if not cell.passable then return false end

   for _, seen in ipairs(sight_component.seenActors) do
      local seen_passable = seen:hasComponent(components.Collideable)
      if
         seen.position.x == vec.x
         and seen.position.y == vec.y
         and seen_passable
         and seen ~= actor
      then
         return false
      end
   end

   return true
end

function AIController.getPassableDirection(actor)
   local options = {}

   local x, y = actor.position.x, actor.position.y
   for i = -1, 1 do
      for j = -1, 1 do
         if AIController.isPassable(actor, Vector2(x + i, y + j)) and not (i == 0 and j == 0) then
            table.insert(options, { i, j })
         end
      end
   end

   if #options < 1 then return Vector2(love.math.random(-1, 1), love.math.random(-1, 1)) end

   return Vector2(unpack(options[love.math.random(1, #options)]))
end

function AIController.moveTowardSimple(actor, target)
   local mx = target.position.x - actor.position.x > 0 and 1
      or target.position.x - actor.position.x < 0 and -1
      or 0
   local my = target.position.y - actor.position.y > 0 and 1
      or target.position.y - actor.position.y < 0 and -1
      or 0

   local moveVec = Vector2(mx, my)
   return actor:getAction(actions.Move)(actor, moveVec)
end

function AIController.moveTowardObject(actor, target)
   AIController.moveTowardPosition(actor, target.position)
end

function AIController:moveTowardPosition(actor, pos)
   local mx = pos.x - actor.position.x > 0 and 1 or pos.x - actor.position.x < 0 and -1 or 0
   local my = pos.y - actor.position.y > 0 and 1 or pos.y - actor.position.y < 0 and -1 or 0

   local moveVec = Vector2(actor.position.x + mx, actor.position.y + my)
   if AIController.isPassable(actor, moveVec) then
      return actor:getAction(actions.Move)(actor, Vector2(mx, my)), moveVec
   end

   local closestDist = vec:getRange("box", actor)
   local closest = Vector2(actor.position.x, actor.position.y)
   local current = Vector2(actor.position.x, actor.position.y)
   for x = actor.position.x - 1, actor.position.x + 1 do
      for y = actor.position.y - 1, actor.position.y + 1 do
         current.x, current.y = x, y
         local dist = vec:getRangec("box", current)

         if
            dist < closestDist
            and AIController.isPassable(actor, current)
            and not (x == target.position.x or y == target.position.y)
         then
            closestDist = dist
            closest.x, closest.y = current.x, current.y
         end
      end
   end

   local moveVec = Vector2(-(actor.position.x - closest.x), -(actor.position.y - closest.y))
   return actor:getAction(actions.Move)(actor, moveVec), moveVec
end

function AIController.move(actor, moveVec) return actor:getAction(actions.Move)(actor, moveVec) end

function AIController.tileHasCreature(actor, current)
   local sight_component = actor:getComponent(components.Sight)
   if not sight_component then return false end

   for _, seen in ipairs(sight_component.seenActors) do
      if seen.position.x == current.x and seen.position.y == current.y then return true end
   end

   return false
end

function AIController.moveToward(actor, target, avoidCreatures)
   return AIController.moveTowardVecAvoid(actor, target.position, avoidCreatures)
end

function AIController.moveTowardVecAvoid(actor, vec, avoidCreatures)
   local mx = vec.x - actor.position.x > 0 and 1 or vec.x - actor.position.x < 0 and -1 or 0
   local my = vec.y - actor.position.y > 0 and 1 or vec.y - actor.position.y < 0 and -1 or 0

   local moveVec = Vector2(actor.position.x + mx, actor.position.y + my)
   if AIController.isPassable(actor, moveVec) then
      return actor:getAction(actions.Move)(actor, Vector2(mx, my)), moveVec
   end

   local closestDist = vec:getRange("box", actor.position)
   local closest = Vector2(actor.position.x, actor.position.y)
   local current = Vector2(actor.position.x, actor.position.y)
   for x = actor.position.x - 1, actor.position.x + 1 do
      for y = actor.position.y - 1, actor.position.y + 1 do
         current.x, current.y = x, y
         local dist = vec:getRange("box", current)

         if dist < closestDist and AIController.isPassable(actor, current) then
            if avoidCreatures and not AIController.tileHasCreature(actor, current) then
               closestDist = dist
               closest.x, closest.y = current.x, current.y
            elseif not avoidCreatures then
               closestDist = dist
               closest.x, closest.y = current.x, current.y
            end
         end
      end
   end

   local moveVec = Vector2(-(actor.position.x - closest.x), -(actor.position.y - closest.y))
   return actor:getAction(actions.Move)(actor, moveVec), moveVec
end

function AIController.crowdAround(actor, target, avoidCreatures)
   local openTiles = {}
   for x = actor.position.x - 1, actor.position.x + 1 do
      for y = actor.position.y - 1, actor.position.y + 1 do
         local current = Vector2(x, y)
         if
            AIController.isPassable(actor, current)
            and not AIController.tileHasCreature(actor, current)
         then
            table.insert(openTiles, current)
         end
      end
   end

   local closest = math.huge
   local closestVec = Vector2(actor.position.x, actor.position.y)

   for i = 1, #openTiles do
      local range
      if target:is(Vector2) then
         range = math.max(target:getRange("box", openTiles[i]), 1)
      else
         range = math.max(target:getRangeVec("box", openTiles[i]), 1)
      end
      if openTiles[i].x == actor.position.x and openTiles.y == actor.position.y then
         if range <= closest then
            closest = range
            closestVec = openTiles[i]
         end
      else
         if range < closest then
            closest = range
            closestVec = openTiles[i]
         end
      end
   end

   local moveVec = Vector2(-(actor.position.x - closestVec.x), -(actor.position.y - closestVec.y))
   return actor:getAction(actions.Move)(actor, moveVec), moveVec
end

function AIController.moveAway(actor, target)
   local mx = target.position.x - actor.position.x > 0 and -1
      or target.position.x - actor.position.x < 0 and 1
      or 0
   local my = target.position.y - actor.position.y > 0 and -1
      or target.position.y - actor.position.y < 0 and 1
      or 0

   if
      AIController.isPassable(actor, Vector2(actor.position.x + mx, actor.position.y + my)) == 0
   then
      local moveVec = Vector2(mx, my)
      return actor:getAction(actions.Move)(actor, moveVec), moveVec
   end

   local furthestDist = target:getRange("box", actor)
   local closest = Vector2(actor.position.x, actor.position.y)
   local current = Vector2(actor.position.x, actor.position.y)
   for x = actor.position.x - 1, actor.position.x + 1 do
      for y = actor.position.y - 1, actor.position.y + 1 do
         current.x, current.y = x, y
         local dist = target.position:getRange("box", current)

         if dist > furthestDist and AIController.isPassable(actor, current) then
            furthestDist = dist
            closest.x, closest.y = current.x, current.y
         end
      end
   end

   local moveVec = Vector2(-(actor.position.x - closest.x), -(actor.position.y - closest.y))
   return actor:getAction(actions.Move)(actor, moveVec), moveVec
end

function AIController.canSeeActor(actor, target)
   local sight_component = actor:getComponent(components.Sight)
   if not sight_component then
      print "Warning: No sight component found for actor"
      return
   end
   for k, v in pairs(sight_component.seenActors) do
      if v == target then return true end
   end

   return false
end

function AIController.canSeeActorType(actor, type)
   local sight_component = actor:getComponent(components.Sight)
   if not sight_component then
      print "Warning: No sight component found for actor"
      return
   end
   for k, v in pairs(sight_component.seenActors) do
      if v:is(type) then return true end
   end

   return false
end

function AIController.closestSeenActorByType(actor, type)
   local sight_component = actor:getComponent(components.Sight)
   if not sight_component then
      print "Warning: No sight component found for actor"
      return
   end

   local closest
   local dist = math.huge
   for _, v in pairs(sight_component.seenActors) do
      if v:is(type) and v:getRange("box", actor) < dist then
         closest = v
         dist = v:getRange("box", actor)
      end
   end

   if closest then assert(closest:is(Actor)) end

   return closest
end

function AIController.closestSeenActorByFaction(actor, faction_tag)
   local sight_component = actor:getComponent(components.Sight)

   local closest
   local dist = math.huge
   for _, v in pairs(sight_component.seenActors) do
      local faction_component = v:getComponent(components.Faction)
      local is_faction = faction_component and faction_component:has(faction_tag)
      if is_faction and v:getRange("box", actor) < dist then
         closest = v
         dist = v:getRange("box", actor)
      end
   end

   if closest then assert(closest:is(Actor)) end

   return closest
end

function AIController.getLightestTile(level, actor)
   local highestLightValue = 0
   local highest = { x = actor.position.x, y = actor.position.y }

   local light_system = level:getSystem "Lighting"
   if not light_system then return highest.x, highest.y, highestLightValue end

   for x = actor.position.x - 1, actor.position.x + 1 do
      for y = actor.position.y - 1, actor.position.y + 1 do
         local light_value = light_system:getLight(x, y)
         if light_value then
            local lightval = light_value:average_brightness()

            if lightval > highestLightValue and AIController.isPassable(actor, Vector2(x, y)) then
               highestLightValue = lightval
               highest.x, highest.y = x, y
            end
         end
      end
   end

   return highest.x, highest.y, highestLightValue
end

function AIController.getDarkestTile(level, actor)
   local lowestLightValue = math.huge
   local lowest = { x = actor.position.x, y = actor.position.y }

   local light_system = level:getSystem "Lighting"
   if not light_system then return lowest.x, lowest.y, lowestLightValue end

   for x = actor.position.x - 1, actor.position.x + 1 do
      for y = actor.position.y - 1, actor.position.y + 1 do
         local light_value = light_system:getLight(x, y)
         if light_value then
            local lightval = light_value:average_brightness()

            if lightval < lowestLightValue and AIController.isPassable(actor, Vector2(x, y)) then
               lowestLightValue = lightval
               lowest.x, lowest.y = x, y
            end
         end
      end
   end

   return lowest.x, lowest.y, lowestLightValue
end

function AIController.moveTowardLight(level, actor)
   local x, y, lightVal = AIController.getLightestTile(level, actor)

   if lightVal == 0 then return AIController.randomMove(level, actor) end

   local moveVec = Vector2(-(actor.position.x - x), -(actor.position.y - y))
   return actor:getAction(actions.Move)(actor, moveVec)
end

function AIController.moveTowardDarkness(level, actor)
   local x, y, lightVal = AIController.getDarkestTile(level, actor)

   local moveVec = Vector2(-(actor.position.x - x), -(actor.position.y - y))
   return actor:getAction(actions.Move)(actor, moveVec)
end

function AIController.randomMove(level, actor)
   assert(actor and actor.is and actor:is(Actor), "Expected actor to be an Actor")
   local moveVec = Vector2(ROT.RNG:random(1, 3) - 2, ROT.RNG:random(1, 3) - 2)
   return actor:getAction(actions.Move)(actor, moveVec), moveVec
end

return AIController
