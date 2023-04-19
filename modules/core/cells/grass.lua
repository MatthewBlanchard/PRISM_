local Cell = require("core.cell")
local Tiles = require("display.tiles")

local Grass = Cell:extend()
Grass.name = "Grass" -- displayed in the user interface
Grass.passable = true -- defines whether a cell is passable
Grass.opaque = false -- defines whether a cell can be seen through
Grass.tile = Tiles["grass_3"]
Grass.sightLimit = 3 -- when standing on this tile does it interfere with sight?
Grass.lightReduction = 4 -- reduces the amount of light that passes through this cell

<<<<<<< HEAD
function Grass:visibleFromCell(level, cell) return cell.grassID == self.grassID end
=======
function Grass:visibleFromCell(level, cell)
	return cell.grassID == self.grassID
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Grass
