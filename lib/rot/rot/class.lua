local BaseClass = {}

function BaseClass:new(...)
<<<<<<< HEAD
   local t = setmetatable({}, self)
   t:init(...)
   return t
end

function BaseClass:extend(name, t)
   t = t or {}
   t.__index = t
   t.super = self
   return setmetatable(t, { __call = self.new, __index = self })
=======
	local t = setmetatable({}, self)
	t:init(...)
	return t
end

function BaseClass:extend(name, t)
	t = t or {}
	t.__index = t
	t.super = self
	return setmetatable(t, { __call = self.new, __index = self })
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

function BaseClass:init() end

return BaseClass
