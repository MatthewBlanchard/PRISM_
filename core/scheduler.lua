local Object = require "object"

local Scheduler = Object:extend()

function Scheduler:__new()
  self.queue = {}
  self.actCount = 0
end

function Scheduler:add(actor, time, lastAct)
  local schedTable = {
    actor = actor,
    time = time or 0,
    lastAct = lastAct or 0,
  }

  insert_sorted(self.queue, schedTable)
end

function Scheduler:remove(actor)
  for i, schedTable in ipairs(self.queue) do
    if schedTable.actor == actor then
      table.remove(self.queue, i)
      return
    end
  end
end

function Scheduler:has(actor)
  for i, schedTable in ipairs(self.queue) do
    if schedTable.actor == actor then
      return true
    end
  end
end

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

local function sortFunction(a, b)
  if a.time == b.time then
    return a.lastAct < b.lastAct
  end
  return a.time < b.time
end

function insert_sorted(list, value)
  local index = 1
  local length = #list

  while index <= length do
    if sortFunction(value, list[index]) then
      break
    end
    index = index + 1
  end

  table.insert(list, index, value)
end

function Scheduler:next()
  self.actCount = self.actCount + 1
  self.queue[1].lastAct = self.actCount
  self:updateTime(self.queue[1].time)

  return self.queue[1].actor
end

function Scheduler:debugPrint()
  for i, schedTable in ipairs(self.queue) do
  end
end

function Scheduler:updateTime(time)
  for i, schedTable in ipairs(self.queue) do
    schedTable.time = schedTable.time - time
  end
end

return Scheduler