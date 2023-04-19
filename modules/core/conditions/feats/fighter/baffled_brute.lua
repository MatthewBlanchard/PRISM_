local Condition = require("core.condition")

local BaffledBrute = Condition:extend()
BaffledBrute.name = "Baffled Brute"
BaffledBrute.description = "You are not very smart, but at least you're strong. +2 ATK -2 MGK"

<<<<<<< HEAD
function BaffledBrute:getATK() return 2 end

function BaffledBrute:getMGK() return -2 end
=======
function BaffledBrute:getATK()
	return 2
end

function BaffledBrute:getMGK()
	return -2
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return BaffledBrute
