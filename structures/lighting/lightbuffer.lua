local Object = require "object"
local LightColor = require "structures.lighting.lightcolor"
local ffi = require "ffi"

local _max, _min = math.max, math.min

local LightBuffer = Object:extend()

function LightBuffer:__new(w, h)
    self.w = w
    self.h = h

    self.buffer = ffi.new("LightColor[?]", w * h)
end

function LightBuffer:getIndex(x, y)
    assert(x > 0 and y > 0, "Index out of bounds (" .. x .. ", " .. y .. "," .. seed .. ")")
    assert(x <= self.w and y <= self.h, "Index out of bounds (" .. x .. ", " .. y .. "," .. seed .. ")")
    assert((y - 1) * self.w + (x - 1) < self.w * self.h, "Index out of bounds (" .. x .. ", " .. y .. "," .. seed .. ")")
    return (y - 1) * self.w + (x - 1)
end

function LightBuffer:clear()
    ffi.fill(self.buffer, ffi.sizeof("LightColor") * self.w * self.h)
end

function LightBuffer:clear_rect(bbox)
    local startX, startY = _max(1, bbox.x), _max(1, bbox.y)
    local endX, endY = _min(self.w, bbox.i), _min(self.h, bbox.j)

    local zeroColor = LightColor(0, 0, 0)

    for i = startX, endX do
        for j = startY, endY do
            local index = self:getIndex(i, j)
            self:setWithFFIStructIndex(index, zeroColor)
        end
    end
end


function LightBuffer:getColor(x, y)
    local color = self.buffer[self:getIndex(x, y)]
    return LightColor(color.r, color.g, color.b)
end

function LightBuffer:getLight(x, y)
    return self:getColor(x, y)
end

function LightBuffer:set(x, y, r, g, b)
    local color = self.buffer[self:getIndex(x, y)]
    color.r, color.g, color.b = r, g, b
end

-- Function to set the color in the LightBuffer
function LightBuffer:setWithFFIStruct(x, y, color)
    local index = self:getIndex(x, y)
    ffi.copy(self.buffer[index], color, ffi.sizeof("LightColor"))
end

function LightBuffer:setWithFFIStructIndex(index, color)
    ffi.copy(self.buffer[index], color, ffi.sizeof("LightColor"))
end

local _lightColor = LightColor(0, 0, 0)
function LightBuffer:accumulate_buffer(x, y, buffer)
    for i = 0, buffer.w - 1 do
        for j = 0, buffer.h - 1 do
            if not (x + i - 1 < 0 or x + i - 1 >= self.w or y + j - 1 < 0 or y + j - 1 >= self.h) then
                local index = self:getIndex(x + i, y + j)
                local bufIndex = buffer:getIndex(i + 1, j + 1)

                _lightColor.r = _max(0, _min(31, self.buffer[index].r + buffer.buffer[bufIndex].r))
                _lightColor.g = _max(0, _min(31, self.buffer[index].g + buffer.buffer[bufIndex].g))
                _lightColor.b = _max(0, _min(31, self.buffer[index].b + buffer.buffer[bufIndex].b))

                self:setWithFFIStructIndex(index, _lightColor)
            end
        end
    end
end

function LightBuffer:accumulate_buffer_masked(x, y, buffer, mask)
    local startX, startY = _max(x, mask.x), _max(y, mask.y)
    local endX, endY = _min(x + buffer.w, mask.i), _min(y + buffer.h, mask.j)

    for i = startX, endX do
        for j = startY, endY do
            local index = self:getIndex(i, j)
            local bufIndex = buffer:getIndex(i - x + 1, j - y + 1)

            _lightColor.r = _max(0, _min(31, self.buffer[index].r + buffer.buffer[bufIndex].r))
            _lightColor.g = _max(0, _min(31, self.buffer[index].g + buffer.buffer[bufIndex].g))
            _lightColor.b = _max(0, _min(31, self.buffer[index].b + buffer.buffer[bufIndex].b))

            self:setWithFFIStructIndex(index, _lightColor)
        end
    end
end


function LightBuffer:fill(r, g, b)
    for i = 0, self.w * self.h - 1 do
        self.buffer[i].r = r
        self.buffer[i].g = g
        self.buffer[i].b = b
    end
end

return LightBuffer