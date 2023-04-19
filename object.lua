local Object = {}

function Object:extend()
<<<<<<< HEAD
   local o = {}
   setmetatable(o, self)
   self.__index = self
   self.__call = self.__call or Object.__call

   return o
=======
	local o = {}
	setmetatable(o, self)
	self.__index = self
	self.__call = self.__call or Object.__call

	return o
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

-- Metamethods
function Object:__call(...)
<<<<<<< HEAD
   local o = {}
   setmetatable(o, self)
   self.__index = self

   o:__new(...)
   return o
=======
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o:__new(...)
	return o
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

-- Constructor
function Object:__new() end

-- Checks if self is a child of o. It will follow
-- the inheritance chain to check if self is a child
-- of o.
function Object:is(o)
<<<<<<< HEAD
   if self == o then return true end

   local parent = getmetatable(self)
   while parent do
      if parent == o then return true end

      parent = getmetatable(parent)
   end

   return false
=======
	if self == o then
		return true
	end

	local parent = getmetatable(self)
	while parent do
		if parent == o then
			return true
		end

		parent = getmetatable(parent)
	end

	return false
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

-- Same functionality as is except it will only check
-- the immediate parent of self.
function Object:extends(o)
<<<<<<< HEAD
   if self == o then return true end

   if getmetatable(self) == o then return true end

   return false
=======
	if self == o then
		return true
	end

	if getmetatable(self) == o then
		return true
	end

	return false
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Object:__call()
