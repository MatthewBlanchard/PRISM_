local Object = require "object"
local GameState = require "gamestates.gamestate"

local StateManager = Object:extend()

function StateManager:__new()
    self.stateStack = {}
end

function StateManager:push(state)
    assert(state:is(GameState), "state must be a subclass of GameState")
    table.push(self.stateStack, state)
    if state.load then
        state:load()
    end
end

function StateManager:pop()
    local topState = self.stateStack[#self.stateStack]
    if topState and topState.unload then
        topState:unload()
    end
    return table.pop(self.stateStack)
end

function StateManager:replace(state)
    assert(state:is(GameState), "state must be a subclass of GameState")
    self:pop()
    self:push(state)
end

function StateManager:update(dt)
    local topState = self.stateStack[#self.stateStack]
    if topState then
        topState:update(dt)
    end
end

function StateManager:draw()
    local topState = self.stateStack[#self.stateStack]
    if topState then
        topState:draw()
    end
end

function StateManager:keypressed(key, scancode)
    local topState = self.stateStack[#self.stateStack]
    if topState then
        topState:keypressed(key, scancode)
    end
end

return StateManager
