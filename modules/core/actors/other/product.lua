local Actor = require "core.actor"
local Action = require "core.action"

local Product = Actor:extend()

local targetProduct = targets.Actor:extend()

function targetProduct:validate(owner, actor)
  return actor:is(actors.Product)
end

Product.components = {
  components.Collideable_box(),
  components.Sellable(),
  components.Usable({actions.Buy}, actions.Buy)
}

function Product:initialize()
  local sellable_component = self:getComponent(components.Sellable)
  self.char = sellable_component.char
  self.color = sellable_component.color
  self.name = sellable_component.name
end
return Product
