-- require is not smart so we are going to wrap it to warn us if we include
-- a file using /s instead of .s
local _require = require
require = function(path)
<<<<<<< HEAD
   if path:find "/" and not path:find "rot" then
      print("WARNING: require(" .. path .. ") uses / instead of .")
   end

   if string.lower(path) ~= path and not path:find "rot" then
      print("WARNING: require(" .. path .. ") uses uppercase letters")
   end

   return _require(path)
=======
	if path:find("/") and not path:find("rot") then
		print("WARNING: require(" .. path .. ") uses / instead of .")
	end

	if string.lower(path) ~= path and not path:find("rot") then
		print("WARNING: require(" .. path .. ") uses uppercase letters")
	end

	return _require(path)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end
