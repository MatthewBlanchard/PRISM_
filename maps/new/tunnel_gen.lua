local Object = require 'object'
local Map = require 'maps.map'
local Cave = require 'maps.chunks.cave'

local TunnelGen = Object:extend()

function TunnelGen:__new()
    self._width = 100
    self._height = 100
    self._map = Map:new(self._width, self._height, 1)
end

function TunnelGen:create(callback)
    local cx, cy = self._map:get_center()
    local y = self._map.height - 5
    self._map:tunneler(cx - 10, y, 3, 0.5, 70, {0, -1}, 30)
    coroutine.yield()
    self._map:tunneler(cx + 10, 5, 2, 0.4, 70, {0, 1}, 30)
    coroutine.yield()
    self._map:tunneler(4, cy, 2, 0.2, 130, {1, 0}, 30)
    coroutine.yield()
    self._map:tunneler(self._map.width - 5, cy, 2, 0.2, 140, {-1, 0}, 30)
    coroutine.yield()

    self._map:remove_isolated_walls()
    coroutine.yield()

    local cave = Cave

    for i = 1, 10 do
        local cave_map = Map:from_chunk(cave)

        local x, y = self._map:get_random_closed_tile()
        while self._map:check_overlap(cave_map, x, y) do
            x, y = self._map:get_random_closed_tile()
        end
    
        print(x, y)
        self._map:blit(cave_map, x, y, false, 1)
    
        coroutine.yield()
    end



    for x, y, cell in self._map:for_cells() do
        callback(x + 1, y + 1, cell)
    end

    local x, y = self._map:get_random_open_tile()
    self._map:insert_actor('Player', x, y)

    return self._map
end

return TunnelGen