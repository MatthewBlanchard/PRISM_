local ROT = require((...):gsub((".[^./\\]*"):rep(1) .. "$", ""))
<<<<<<< HEAD
local Noise = ROT.Class:extend "Noise"
=======
local Noise = ROT.Class:extend("Noise")
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

function Noise:get() end

return Noise
