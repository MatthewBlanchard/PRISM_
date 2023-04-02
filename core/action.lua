--- A class representing an Action that an actor can take in a game.
-- An Action consists of an owner, a name, a list of targets, and a list of target actors.
-- This class is derived from the Object class.
-- @class Action
-- @extends Object
local Object = require "object"

local Action = Object:extend()

--- The time it takes to perform this action
Action.time = 100

--- Constructor for the Action class.
-- @tparam actor owner The actor that is performing the action.
-- @tparam[opt] table targets An optional list of target objects that the action will affect.
function Action:__new(owner, targets)
  self.owner = owner
  self.name = self.name or "ERROR"
  self.targets = self.targets or {}
  self.targetActors = targets or {}

  assert(#self.targetActors == #self.targets, "Invalid number of targets for action " .. self.name .. " expected " .. #self.targets .. " got " .. #self.targetActors)
  for i, target in ipairs(self.targets) do
    assert(target:validate(owner, self.targetActors[i]), "Invalid target " .. i .. " for action " .. self.name)
  end
end

--- Returns the target actor at the specified index.
-- @tparam number n The index of the target actor to retrieve.
-- @treturn[1] actor The target actor at the specified index.
-- @return[2] nil If no target actor exists at that index.
function Action:getTarget(n)
  if self.targetActors[n] then
    return self.targetActors[n]
  end
end

--- Returns the number of targets associated with this action.
-- @treturn number The number of targets associated with this action.
function Action:getNumTargets()
  if not self.targets then return 0 end
  return #self.targets
end

--- Returns a list of target actors associated with this action.
-- @treturn table A list of target actors associated with this action.
function Action:getTargets()
  return self.targetActors
end

--- Returns the target object at the specified index.
-- @tparam number index The index of the target object to retrieve.
-- @treturn[1] table The target object at the specified index.
-- @return[2] nil If no target object exists at that index.
function Action:getTargetObject(index)
  return self.targets[index]
end

--- Determines if the specified actor is a target of this action.
-- @tparam actor actor The actor to check if they are a target of this action.
-- @treturn boolean true if the specified actor is a target of this action, false otherwise.
function Action:hasTarget(actor)
  for _, a in pairs(self.targetActors) do
    if a == actor then return true end
  end
end

--- Validates the specified target for this action.
-- @tparam number n The index of the target object to validate.
-- @tparam actor owner The actor that is performing the action.
-- @tparam table toValidate The target actor to validate.
-- @treturn boolean true if the specified target actor is valid for this action, false otherwise.
function Action:validateTarget(n, owner, toValidate)
  return self.targets[n]:validate(owner, toValidate)
end

return Action