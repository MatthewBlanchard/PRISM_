--- A simple class system for Lua. This is the base class for all other classes in PRISM.
-- @classmod Object

local Object = {}

--- Creates a new class and sets it's metatable to the extended class.
-- @treturn table The new class.
function Object:extend()
   local o = {}
   setmetatable(o, self)
   self.__index = self
   self.__call = self.__call or Object.__call

   return o
end

--- Creates a new instance of the class. Calls the __new method.
-- @treturn table The new instance.
function Object:__call(...)
   local o = {}
   setmetatable(o, self)
   self.__index = self

   o:__new(...)
   return o
end

--- The default constructor for the class. Subclasses should override this.
function Object:__new() end

--- Checks if o is in the inheritance chain of self.
-- @tparam table o The class to check.
-- @treturn boolean True if o is in the inheritance chain of self, false otherwise.
function Object:is(o)
   if self == o then return true end

   local parent = getmetatable(self)
   while parent do
      if parent == o then return true end

      parent = getmetatable(parent)
   end

   return false
end

--- Checks if o is the first class in the inheritance chain of self.
-- @tparam table o The class to check.
-- @treturn boolean True if o is the first class in the inheritance chain of self, false otherwise.
function Object:extends(o)
   if self == o then return true end

   if getmetatable(self) == o then return true end

   return false
end

return Object:__call()
