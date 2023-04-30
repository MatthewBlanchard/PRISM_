local Panel = require "panels.panel"
local Vector2 = require "math.vector"

local Level = Panel:extend()

function Level:__new(display)
   Panel.__new(self, display)
   self.scale = 1

   self.stack = {}
   self.t = 0

   self.waitTime = nil

   self.fov = {}
end


function Level:update(dt)
   self.t = (self.t + dt)
   self.dt = dt

   if self.waitTime then
      self.waitTime = self.waitTime - dt
      if self.waitTime <= 0 then self.waitTime = nil end
   end

   self.fov = SparseGrid()
   self.seenActors = {}

   for actor, sight_component in game.level:eachActor(components.Sight) do
      if game.level:getActorController(actor) then
         for _, actor in pairs(sight_component.seenActors) do
            local found = false
            for _, other in ipairs(self.seenActors) do
               if actor == other then found = true end
            end

            if not found then table.insert(self.seenActors, actor) end
         end

         for x, y, cell in sight_component.fov:each() do
            self.fov:set(x, y, cell)
         end
      end
   end

   if not self:peek() then return end
   self:peek():update(dt)
end

local function value(c) return (c[1] + c[2] + c[3]) / 3 end

local function clerp(start, finish, t)
   local c = {}
   for i = 1, 4 do
      if not start[i] or not finish[i] then break end
      c[i] = (1 - t) * start[i] + t * finish[i]
   end

   return c
end

local function shouldDrawExplored(explored, x, y)
   local cell = explored:get(x, y)
   if not cell then return false end
   if cell.passable then return true end

   for i = -1, 1 do
      for j = -1, 1 do
         local neighbor = explored:get(x + i, y + j)
         if neighbor and neighbor.passable then return true end
      end
   end
end

local ambientColor = { 0.175, 0.175, 0.175 }
function Level:draw()
   local sight_component = game.curActor:getComponent(components.Sight)
   local fov = self.fov
   local explored = sight_component.explored
   local seenActors = self.seenActors
   local scryActors = sight_component.scryActors

   local drawn_actors = {}
   local rememberedActors = {}

   for _, _, actor in sight_component.rememberedActors:each() do
      table.insert(rememberedActors, actor)
   end

   local lighting_system = game.level:getSystem "Lighting"
   lighting_system:rebuildLighting(game.level, self.dt)
   local ambientValue = sight_component.darkvision / 31

   local function tileLightingFormula(color, brightness)
      local finalColor
      local t = math.min(1, math.max(brightness - ambientValue, 0))
      t = math.min(t / (1 - ambientValue), 1)
      finalColor = clerp(ambientColor, color, t)

      if brightness ~= brightness then finalColor = ambientColor end
      return finalColor
   end

   local viewX, viewY = self.display.widthInChars, self.display.heightInChars
   local sx, sy = game.curActor.position.x, game.curActor.position.y

   if game.level:getSystem "Animate" then
      game.level:getSystem "Animate" :updateTimers()
   end
   
   for x = sx - viewX, sx + viewX do
      for y = sy - viewY, sy + viewY do
         local cell = fov:get(x, y)
         if cell then
            local lightCol = lighting_system:getLightingAt(x, y, fov, self.dt):to_rgb()
            local lightValue = lighting_system:getBrightness(x, y, fov) / 31

            local finalColor = tileLightingFormula(lightCol, lightValue)

            if lightValue ~= lightValue then finalColor = ambientColor end
            self:write_plain(cell.tile, x, y, finalColor)
         elseif shouldDrawExplored(explored, x, y) then
            self:write_plain(explored:get(x, y).tile, x, y, ambientColor)
         end
      end
   end

   local function getAnimationChar(actor)
      if not actor:hasComponent(components.Animated) then return actor.char end

      local animation = actor:getComponent(components.Animated)
      if self.t % 0.600 > 0.400 then
         return animation.sheet[2]
      else
         return animation.sheet[1]
      end
   end

   local distortion = false
   for k, actor in pairs(seenActors) do
      if actor:hasComponent(components.Realitydistortion) then distortion = true end
   end

   if distortion then
      game.music:startDistortion()
   else
      game.music:endDistortion()
   end

   local function drawActors(actorTable, conditional)
      for _, actor in ipairs(actorTable) do
         local char = getAnimationChar(actor)
         if conditional and conditional(actor) or true then
            for vec in game.level:eachActorTile(actor) do
               local x, y = vec.x, vec.y
               local lightcolor = lighting_system:getLightingAt(x, y, fov, self.dt):to_rgb()
               if actorTable == scryActors then
                  self:write(char, x, y, actor.color)
               elseif lightcolor then
                  local lightValue = lighting_system:getBrightness(x, y, fov) / 31
                  local t = math.max(lightValue - ambientValue, 0)
                  t = math.min(t / (1 - ambientValue), 1)

                  local finalColor = clerp(ambientColor, actor.color, t)
                  if actor.tileLighting then
                     finalColor = tileLightingFormula(lightcolor, lightValue)
                  end

                  if actor:getComponent(components.Drawable) then
                     local drawable = actor:getComponent(components.Drawable)
                     if game.level:getSystem("Animate") then
                        if not drawn_actors[actor] then game.level:getSystem "Animate" :animate(game.level, actor) end
                     else
                        drawable.object:set_pos(vec)
                     end

                     drawable.object.colors.fg = finalColor
                     self:write_object(drawable.object)
                  else
                     self:write_plain(char, x, y, finalColor)
                  end
                  drawn_actors[actor] = true
               end
            end
         end
      end
   end

   drawActors(rememberedActors)
   drawActors(scryActors)

   -- draw things that don't move furst
   drawActors(seenActors, function(actor) return not actor:hasComponent(components.Move) end)

   -- next up draw things that move but don't block movement
   drawActors(
      seenActors,
      function(actor)
         return actor:hasComponent(components.Move)
            and not actor:hasComponent(components.Collideable)
      end
   )

   -- now we draw the stuff that moves and blocks movement
   drawActors(
      seenActors,
      function(actor)
         return actor:hasComponent(components.Move) and actor:hasComponent(components.Collideable)
      end
   )

   drawActors({ game.curActor }, function() return true end)

   local effect_system = game.level:getSystem "Effects"

   self.effectWrite = false
   while not self.effectWrite and #effect_system.effects ~= 0 do
      for i = #effect_system.effects, 1, -1 do
         local curEffect = effect_system.effects[i]
         self._curEffectDone = true
         local done = curEffect(self.dt, self) or self._curEffectDone

         if done then table.remove(effect_system.effects, i) end
      end
   end

   do
      local drawable = game.curActor:getComponent(components["Drawable"])
      if drawable and game.level:getSystem("Animate") then
         local viewX, viewY = self.display.widthInChars, self.display.heightInChars

         local x2 = (drawable.object.x - game.curActor.position.x)
         local y2 = (drawable.object.y - game.curActor.position.y)

         self.camera_transform.x = (( (-game.curActor.position.x - x2 + 0.5)*self.camera_transform.sx + viewX/2) * 15)
         self.camera_transform.y = (( (-game.curActor.position.y - y2 + 0.5)*self.camera_transform.sy + viewY/2) * 15)

         self.display:update_camera_transform(self.camera_transform)
      end
   end




   if not self:peek() then self.display:draw() return end
   self:peek():draw()
   self.display:draw()
end

function Level:setAction(action) self.action = action end

function Level:getAction()
   local action = self.action
   self.action = nil
   return action
end

function Level:push(panel) table.insert(self.stack, panel) end

function Level:pop()
   local panel = self.stack[#self.stack]
   self.stack[#self.stack] = nil
   return panel
end

function Level:peek() return self.stack[#self.stack] end

function Level:reset()
   for i = 1, #self.stack do
      self.stack[i] = nil
   end
end

return Level