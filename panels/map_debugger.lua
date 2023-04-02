local Panel = require "panels.panel"
local Vector2 = require "math.vector"

local Wall = require "cells.wall"
local Cell = require "cell"

local Start = Panel:extend()

function Start:__new(display, parent, level)
    Panel.__new(self, display, parent)
    self.level = level

    self.offset = Vector2(0, 0)

    self.coroutine = coroutine.create(level.create)
    local success, ret = coroutine.resume(self.coroutine, level, function() end)
    if success == false then
        error(ret .. "\n" .. debug.traceback(self.coroutine))
    end
end

function Start:update(dt)
end

function Start:draw()
    local viewX, viewY = self.display.widthInChars, self.display.heightInChars
    local sx, sy = self.offset.x, self.offset.y

    for x = 1, viewX do
        for y = 1, viewY do
            local worldX = x + sx - math.floor(viewX / 2) - 1
            local worldY = y + sy - math.floor(viewY / 2) - 1
            local tile = Cell.tile

            if self.level._map.map[worldX] and self.level._map.map[worldX][worldY] == 1 then
                tile = Wall.tile
            end

            self.display:write(tile, x, y, {1, 1, 1})
        end
    end
end


function Start:handleKeyPress(keypress)
    local movementTranslation = {
        -- cardinal
        w = Vector2(0, -1),
        s = Vector2(0, 1),
        a = Vector2(-1, 0),
        d = Vector2(1, 0),
      
        -- diagonal disable these and change the target in the Move action
        -- if you want to disable diagonal movement
        q = Vector2(-1, -1),
        e = Vector2(1, -1),
        z = Vector2(-1, 1),
        c = Vector2(1, 1),
    }

    print(self.offset)
    local movement = movementTranslation[keypress]
    if movement then
        self.offset = self.offset + movement
    end

    if keypress == "space" then
        if coroutine.status(self.coroutine) == "dead" then
            print "ENDING"
            game.interface:pop()
        else
            local success, ret = coroutine.resume(self.coroutine)
            if success == false then
                error(ret .. "\n" .. debug.traceback(self.coroutine))
            end
        end
    end
end

return Start
