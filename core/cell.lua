--- A cell is a single tile on the map. It defines the properties of the tile and has a few callbacks.
-- Maybe cells should have components so that they can be extended with custom functionality like the grass?
-- Still working on the details there. For now, cells are just a simple way to define the properties of a tile.
-- @classmod Cell

local Object = require "object"
local Tiles = require "display.tiles"

local Cell = Object:extend()

--- Displayed in the user interface.
-- @tfield string name
Cell.name = "Air"

--- Defines the tile appearance.
-- @tfield number tile
Cell.tile = Tiles["floor"]

--- Defines whether a cell is passable.
-- @tfield boolean passable
Cell.passable = true

--- Defines whether a cell can be seen through.
-- @tfield boolean opaque
Cell.opaque = false

--- If set to an integer, an actor standing on this tile's sight range will be limited to this number.
-- @tfield[opt] number sightLimit
Cell.sightLimit = nil

--- Applies a penalty to speed when moving through this cell by the integer value in this field.
-- @tfield[opt] number movePenalty
Cell.movePenalty = 0

--- Reduces the amount of light that passes through this cell by the integer value in this field.
-- @tfield[opt] number lightReduction
Cell.lightReduction = 1

--- Constructor for the Cell class.
function Cell:__new() end

--- Called when an actor enters the cell.
-- @tparam Level level The level where the actor entered the cell.
-- @tparam Actor actor The actor that entered the cell.
function Cell:onEnter(level, actor) end

--- Called when an actor leaves the cell.
-- @tparam Level level The level where the actor left the cell.
-- @tparam Actor actor The actor that left the cell.
function Cell:onLeave(level, actor) end

--- Called when an action is taken on the cell.
-- @tparam Level level The level where the action took place.
-- @tparam Actor actor The actor that took the action.
-- @tparam Action action The action that was taken.
function Cell:onAction(level, actor, action) end

--- Determines if a cell is visible from another cell.
-- Cells can have custom functions to determine whether an actor standing on them can be seen.
-- For instance, grass cells allow actors to be seen only if the other actor is in the same
-- clump of grass.
-- @tparam Level level The level where the visibility check is taking place.
-- @tparam Cell cell The cell from which visibility is being checked.
-- @return boolean True if the cell is visible from the provided cell, false otherwise.
function Cell:visibleFromCell(level, cell) return true end

return Cell
