--- The 'Scheduler' manages a queue of actors and schedules their actions based on time.
-- @classmod Scheduler

local Object = require "object"

local Scheduler = Object:extend()

--- Constructor for the Scheduler class.
-- Initializes an empty queue and sets the actCount to 0.
function Scheduler:__new()
   self.queue = {}
   self.actCount = 0
end

--- Adds an actor to the scheduler.
-- @tparam Actor actor The actor to add.
-- @tparam number time The current time of the actor.
-- @tparam number lastAct The time of the actor's last action.
function Scheduler:add(actor, time, lastAct)
   local schedTable = {
      actor = actor,
      time = time or 0,
      lastAct = lastAct or 0,
   }

   insert_sorted(self.queue, schedTable)
end

--- Removes an actor from the scheduler.
-- @tparam Actor actor The actor to remove.
function Scheduler:remove(actor)
   for i, schedTable in ipairs(self.queue) do
      if schedTable.actor == actor then
         table.remove(self.queue, i)
         return
      end
   end
end

--- Checks if an actor is in the scheduler.
-- @tparam Actor actor The actor to check.
-- @treturn boolean True if the actor is in the scheduler, false otherwise.
function Scheduler:has(actor)
   for i, schedTable in ipairs(self.queue) do
      if schedTable.actor == actor then return true end
   end
end

--- Adds time to an actor's current time in the scheduler.
-- @tparam Actor actor The actor whose time to add.
-- @tparam number time The amount of time to add.
function Scheduler:addTime(actor, time)
   for i, schedTable in ipairs(self.queue) do
      if schedTable.actor == actor then
         schedTable.time = schedTable.time + time
         -- Re-insert the updated schedTable into the sorted queue
         table.remove(self.queue, i)
         insert_sorted(self.queue, schedTable)
         return
      end
   end

   error "Attempted to add time to an actor not in the scheduler!"
end

--- Sorts the queue based on actors' time and their last action's time.
-- @tparam table a The first actor to compare.
-- @tparam table b The second actor to compare.
-- @treturn boolean True if 'a' should be scheduled before 'b', false otherwise.
local function sortFunction(a, b)
   if a.time == b.time then return a.lastAct < b.lastAct end
   return a.time < b.time
end

function insert_sorted(list, value)
   local left = 1
   local right = #list
   local mid

   while left <= right do
      mid = math.floor((left + right) / 2)
      if sortFunction(value, list[mid]) then
         right = mid - 1
      else
         left = mid + 1
      end
   end

   table.insert(list, left, value)
end

--- Returns the next actor to act.
-- @treturn Actor The actor who is next to act.
function Scheduler:next()
   self.actCount = self.actCount + 1
   self.queue[1].lastAct = self.actCount
   self:updateTime(self.queue[1].time)

   return self.queue[1].actor
end

--- Provides a string representation of the scheduler, listing all actors in the queue with their time and lastAct.
-- @treturn string The string representation of the scheduler.
function Scheduler:__tostring()
   local concat_table = {}
   for i, schedTable in ipairs(self.queue) do
      table.insert(
         concat_table,
         schedTable.actor.name .. " " .. schedTable.time .. " " .. schedTable.lastAct
      )
   end

   return table.concat(concat_table, "\n")
end

--- Updates the time for all actors in the scheduler.
-- @tparam number time The amount of time to subtract from each actor's current time.
function Scheduler:updateTime(time)
   for i, schedTable in ipairs(self.queue) do
      schedTable.time = schedTable.time - time
   end
end

return Scheduler
