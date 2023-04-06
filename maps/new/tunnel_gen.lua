local Object = require 'object'
local Map = require 'maps.map'

local Cave = require 'maps.chunks.cave'
local Hallway = require 'maps.chunks.hallway'
local Tunnel = require 'maps.chunks.tunnel'
local Filler = require 'maps.chunks.filler'
local SmallRoom = require 'maps.chunks.smallroom'
local SqeetoHive = require 'maps.chunks.sqeeto_hive'
local Circle = require 'maps.chunks.circle'
local SpiderNest = require 'maps.chunks.spider_nest'

local TunnelGen = Object:extend()

function TunnelGen:__new(debug)
    self.debug = debug or false
    self._width = 75
    self._height = 75
    self._map = Map:new(self._width, self._height, 1)
end

function TunnelGen:debugYield()
    if self.debug then
        coroutine.yield()
    end
end

function TunnelGen:create(callback)
    local cx, cy = self._map:get_center()
    local y = self._map.height - 5
    self._map:tunneler(cx - 10, y, 3, 0.5, 50, {0, -1}, 30)
    self:debugYield()
    self._map:tunneler(cx + 10, 5, 2, 0.4, 50, {0, 1}, 30)
    self:debugYield()
    self._map:tunneler(4, cy, 2, 0.2, 70, {1, 0}, 100)
    self:debugYield()
    
    local x, y = self._map:get_random_open_tile()
    self._map:insert_actor('Player', x, y)

    for i = 1, 10 do
        local x, y = self._map:get_random_open_tile()
        self._map:insert_actor('Sqeeto', x, y)
    end

    print "FINISHED TUNNELING"

    for i = 1, 10 do
        local x, y = self._map:get_random_open_tile()
        local light_sources = {
            "Glowshroom_1",
            "Glowshroom_2",
        }

        self._map:insert_actor(light_sources[math.random(1, #light_sources)], x, y)
    end

    local cave = Cave

    local special_maps = {
        SqeetoHive,
        SpiderNest
    }

    print(#special_maps)

    for i = 1, 300 do
        local maps = {
            Cave,
            Filler,
            Circle,
            ---SmallRoom
        }

        local doors = {
            "Door",
            "Gate",
            "Breakable_wall"
        }

        local cave_map = Map:from_chunk(maps[math.random(1, #maps)])

        if #special_maps > 0 then
            cave_map = Map:from_chunk(special_maps[math.random(1, #special_maps)])
            table.remove(special_maps, 1)
        end

        local roomTiles, door = self._map:room_accretion(cave_map)

        if roomTiles then
            self._map:set_cell(door[1], door[2], 0)
            self._map:insert_actor(doors[math.random(1, #doors)], door[1], door[2])
        end

        if i % 1 == 0 then
            self:debugYield()
        end
    end

    print "FINISHED ROOM ACCRETION"

    for i = 1, 20 do
        local x, y = self._map:find_wall_tiles_to_remove()
        self:debugYield()
    end

    print "FINDING WALL TILES TO REMOVE"

    for i = 1, 20 do
        local x, y = self._map:get_random_open_tile()
        local light_sources = {
            "Glowshroom_1",
            "Glowshroom_2",
        }

        self._map:insert_actor(light_sources[math.random(1, #light_sources)], x, y)
    end

    for i = 1, 100 do
        local x, y = self._map:get_random_open_tile()
        self._map:insert_actor('Snip', x, y)
    end

    for x, y, cell in self._map:for_cells() do
        callback(x + 1, y + 1, cell)
    end

    return self._map
end

return TunnelGen