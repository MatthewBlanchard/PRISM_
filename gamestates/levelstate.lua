local GameState = require "gamestates.gamestate"
local Interface = require "interface"
local Display = require "display.display"
local Start = require "panels.start"

local PROFILE = false

local LevelState = GameState:extend()
-- This state is passed a Level object and sets up the interface and main loop for
-- the level.
function LevelState:__new(level, depth)
	self.depth = depth
	self.level = level
	self.storedKeypress = nil
	self.updateCoroutine = coroutine.create(level.run)
	self.waiting = false
	self.skipAnimation = false
	self.dt = 0
	self.turnDT = 0
end

function LevelState:load()
	local interface = Interface(game.display)
	interface:push(Start(game.display, interface))

	game.level = self.level
	game.interface = interface

	local player = game.Player
	game.curActor = player

	local torch = actors.Torch()
	table.insert(player:getComponent(components.Inventory).inventory, torch)
	table.insert(player:getComponent(components.Inventory).inventory, actors.Wand_of_fireball())

	love.keyboard.setKeyRepeat(true)
end

function LevelState:update(dt)
	self.dt = dt
	local effects = game.level:getSystem "Effects"

	game.music:update(dt)
	game.interface:update(dt, game.level)

	local awaitedAction = game.interface:getAction()

	-- the game has told us to pause execution and draw frames for a while
	if game.interface.waitTime and game.interface.waitTime > 0 and not self.skipAnimation then
		return
	end

	-- don't advance game state while we're rendering effects please
	if effects and #effects.effects ~= 0 then return end

	-- we're waiting and there's no input so stop advancing
	if self.waiting and not awaitedAction then return end
	self.waiting = false

	local success, ret
	local startTime = love.timer.getTime()
	-- when we press a key during animations we want to skip them
	repeat
		if PROFILE and awaitedAction then profiler.start() end
		startTime = love.timer.getTime()
		success, ret, time = coroutine.resume(self.updateCoroutine, game.level, awaitedAction)
		if success == false then error(ret .. "\n" .. debug.traceback(self.updateCoroutine)) end
		if PROFILE and awaitedAction then
			profiler.stop()
			profiler.writeReport "profile.txt"
		end
	until not (ret == "effect" and self.skipAnimation)

	local coroutine_status = coroutine.status(self.updateCoroutine)
	if coroutine_status == "suspended" and ret.is and ret:is(Actor) then
		-- if level update returns a table we know we've got out guy so we set
		-- curActor to let the interface know to unlock input
		self.turnDT = love.timer.getTime() - startTime
		assert(ret:is(Actor))
		game.curActor = ret
		self.waiting = true
		self.skipAnimation = false
		if self.storedKeypress then
			love.keypressed(self.storedKeypress[1], self.storedKeypress[2])
		end

		effects.effects = {}
	elseif coroutine_status == "suspended" and ret == "wait" then
		game.interface.waitTime = time
	elseif coroutine_status == "dead" then
		-- The coroutine has not stopped running and returned "descend".
		-- It's time for us to load a new level.
		if ret == "descend" then
			self.manager:pop()
			self.manager:push(LevelState(game:generateLevel(1), 2))
		else
			love.event.quit(0)
		end
	end
end

function LevelState:draw()
	if not game.display then return end
	game.viewDisplay:clear()
	game.display:clear()
	game.interface:draw(game.display)
	game.viewDisplay:draw()
	game.display:draw "UI"

	love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
	love.graphics.print("TurnDT: " .. self.turnDT, 10, 20)
end

function LevelState:keypressed(key, scancode)
	local effects = game.level:getSystem "Effects"

	if not self.waiting then
		effects.effects = {}
		self.skipAnimation = true
		self.storedKeypress = { key, scancode }
		return
	end

	self.storedKeypress = nil
	-- if there is no current actor than we freeze input
	game.interface:handleKeyPress(key, scancode)
end

return LevelState
