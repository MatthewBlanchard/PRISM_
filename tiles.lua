local json = require 'lib.json'
local atlas = love.filesystem.read('display/atlas.json')

local tile_mapping = json.decode(atlas)
local tiles = {}
for k, v in pairs(tile_mapping.regions) do
	tiles[v.name] = v.idx
end

return tiles
