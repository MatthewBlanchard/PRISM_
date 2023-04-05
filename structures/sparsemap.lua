local Object = require "object"

local math_floor = math.floor
local function hash(x, y)
    return x and y * 0x4000000 + x --  26-bit x and y
end

local function unhash(hash)
    return hash % 0x4000000, math_floor(hash / 0x4000000)
end

local dummy = {}
local SparseMap = Object:extend()

function SparseMap:__new()
    self.__count = 0
    self.map = {}
    self.list = {}
end

function SparseMap:get(x, y)
    return self.map[hash(x, y)] or dummy
end

function SparseMap:getByHash(hash)
    return self.map[hash] or dummy
end

function SparseMap:each()
    local key, val
    return function()
        key, val = next(self.list, key)
        if key then
            return val[1], val[2], key
        end
        return nil
    end
end

-- This shouldn't be called often as it's going to be relatively expensive.
function SparseMap:count()
    return self.__count
end

function SparseMap:countCell(x, y)
    local count = 0

    for _, _ in pairs(self.map[hash(x, y)] or dummy) do
        count = count + 1
    end

    return count
end

function SparseMap:has(x, y, value)
    local xyhash = hash(x, y)
    if not self.map[xyhash] then return false end
    return self.map[xyhash][value] or false
end

function SparseMap:insert(x, y, val)
    local xyhash = hash(x, y)
    if not self.map[xyhash] then self.map[xyhash] = {} end

    self.__count = self.__count + 1
    self.list[val] = {x, y}
    self.map[xyhash][val] = true
end

function SparseMap:remove(x, y, val)
    local xyhash = hash(x, y)
    if not self.map[xyhash] then return false end
    
    self.__count = self.__count - 1
    self.list[val] = nil
    self.map[xyhash][val] = nil
    return true
end

local test = SparseMap()
test:insert(1, 1, "test")
test:insert(1, 2, "test2")
test:insert(3, 1, "test3")

assert(test:count() == 3)
assert(test:countCell(1, 1) == 1)
assert(test:countCell(1, 2) == 1)
assert(test:countCell(3, 1) == 1)
assert(test:has(1, 1, "test"))
assert(test:has(1, 2, "test2"))
assert(test:has(3, 1, "test3"))
assert(test:get(1, 1).test)
assert(test:get(1, 2).test2)
assert(test:get(3, 1).test3)
assert(not test:has(1, 1, "test4"))
assert(test:remove(1, 1, "test"))
assert(test:count() == 2)
return SparseMap