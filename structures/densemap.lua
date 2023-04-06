local Object = require "object"
local LightColor = require "lighting.lightcolor"
local ffi = require "ffi"

local _max, _min = math.max, math.min

local Buffer = Object:extend()

function Buffer:__new(w, h)
    self.w = w
    self.h = h

    self.buffer = ffi.new("bool[?]", w * h)
end

function Buffer:getIndex(x, y)
    return (y - 1) * self.w + (x - 1)
end

function Buffer:clear()
    ffi.fill(self.buffer, ffi.sizeof("bool") * self.w * self.h)
end

function Buffer:set(x, y, v)
    self.buffer[self:getIndex(x, y)] = v
end

function Buffer:get(x, y)
    return self.buffer[self:getIndex(x, y)]
end

return Buffer