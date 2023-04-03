local Object = require 'object'
local Map = require 'maps.map'

local Cave = require 'maps.chunks.cave'
local Hallway = require 'maps.chunks.hallway'
local Tunnel = require 'maps.chunks.tunnel'
local Filler = require 'maps.chunks.filler'

local TunnelGen = Object:extend()

function TunnelGen:__new()
    self._width = 75
    self._height = 75
    self._map = Map:new(self._width, self._height, 1)
end

function TunnelGen:create(callback)
    local cx, cy = self._map:get_center()
    local y = self._map.height - 5
    self._map:tunneler(cx - 10, y, 3, 0.5, 50, {0, -1}, 30)
    coroutine.yield()
    self._map:tunneler(cx + 10, 5, 2, 0.4, 50, {0, 1}, 30)
    coroutine.yield()
    self._map:tunneler(4, cy, 2, 0.2, 30, {1, 0}, 20)
    coroutine.yield()
    self._map:tunneler(self._map.width - 5, cy, 2, 0.2, 30, {-1, 0}, 20)
    coroutine.yield()

    local cave = Cave

    for i = 1, 100 do
        local maps = {
            Cave,
            Filler,
        }

        local cave_map = Map:from_chunk(maps[math.random(1, #maps)])

        local door = self._map:room_accretion(cave_map)

        if door then
            for k,v in pairs(door) do
                print(k,v)
            end
            self._map:set_cell(door[1], door[2], 0)
        end

        if i % 10 == 0 then
            coroutine.yield()
        end
    end

    for i = 1, 20 do
        local x, y = self._map:get_random_open_tile()
        local path = self._map:drunkWalk(x, y,
            function(x, y, i, chunk)  
                return (i > 20) or (x < 5 or x > chunk.width-5 or y < 5 or y > chunk.height-5)
            end
        )

        self._map:clear_path(path)
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