local Object = require 'object'
local Map = require 'maps.map'

local TunnelGen = Object:extend()

function TunnelGen:__new()
    self._width = 100
    self._height = 100
    self._map = Map:new(self._width, self._height, 1)
end

function TunnelGen:create(callback)
    print "HELLO"
    self._map:tunneler(math.random(1, self._width), math.random(1, self._height), 4, 0.02, 300)
    print "1"
    coroutine.yield()
    self._map:tunneler(math.random(1, self._width), math.random(1, self._height), 4, 0.02, 300)
    print "2"
    coroutine.yield()
    self._map:tunneler(math.random(1, self._width), math.random(1, self._height), 3, 0.05, 300)
    coroutine.yield()
    self._map:tunneler(math.random(1, self._width), math.random(1, self._height), 3, 0.05, 300)
    coroutine.yield()
    self._map:tunneler(math.random(1, self._width), math.random(1, self._height), 3, 0.05, 100)
    coroutine.yield()
    self._map:tunneler(math.random(1, self._width), math.random(1, self._height), 2, 0.1, 300)
    coroutine.yield()
    self._map:tunneler(math.random(1, self._width), math.random(1, self._height), 2, 0.1, 300)
    coroutine.yield()
    self._map:tunneler(math.random(1, self._width), math.random(1, self._height), 1, 0.1, 300)
    coroutine.yield()

    for x, y, cell in self._map:for_cells() do
        callback(x + 1, y + 1, cell)
    end

    local x, y = self._map:get_random_open_tile()
    self._map:insert_actor('Player', x, y)

    print "DONE"
    return self._map
end

return TunnelGen