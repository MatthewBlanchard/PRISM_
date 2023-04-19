local ROT = require((...):gsub((".[^./\\]*"):rep(2) .. "$", ""))
<<<<<<< HEAD
local Feature = ROT.Class:extend "Feature"
=======
local Feature = ROT.Class:extend("Feature")
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

function Feature:isValid() end
function Feature:create() end
function Feature:debug() end
function Feature:createRandomAt() end
return Feature
