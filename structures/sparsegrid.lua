local Object = require "object"

local function hash(x, y)
   return x and y * 0x4000000 + x --  26-bit x and y
end

local function unhash(hash) return hash % 0x4000000, math.floor(hash / 0x4000000) end

SparseGrid = Object:extend()

function SparseGrid:__new()
   self.data = {}
   return self
end

function SparseGrid:set(x, y, value)
   local key = hash(x, y)
   self.data[key] = value
end

function SparseGrid:get(x, y)
   local key = hash(x, y)
   return self.data[key]
end

function SparseGrid:clear()
   for k in pairs(self.data) do
      self.data[k] = nil
   end
end

-- Iterator function for SparseGrid
function SparseGrid:each()
   local nextIndex, nextValue = next(self.data)
   return function()
      local currentIndex, currentValue = nextIndex, nextValue
      if currentIndex then
         nextIndex, nextValue = next(self.data, currentIndex)
         local x, y = unhash(currentIndex)
         return x, y, currentValue
      end
   end
end

return SparseGrid
