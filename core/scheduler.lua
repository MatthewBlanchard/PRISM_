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
		if schedTable.actor == actor then return true end
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

function Scheduler:next()
	self.actCount = self.actCount + 1
	self.queue[1].lastAct = self.actCount
	self:updateTime(self.queue[1].time)

	return self.queue[1].actor
end

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

function Scheduler:updateTime(time)
	for i, schedTable in ipairs(self.queue) do
		schedTable.time = schedTable.time - time
	end
end

return Scheduler
