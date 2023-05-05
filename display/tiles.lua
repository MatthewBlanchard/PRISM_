local json = require "lib.json"
local atlas = json.decode(love.filesystem.read("display/atlas" .. ".json"))

local sorted = {}
for i, v in ipairs(atlas.regions) do
   sorted[v.idx] = v
end

local tiles = {}
for k, v in ipairs(sorted) do
   tiles[v.name] = v.idx
end

return tiles
